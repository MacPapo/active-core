# frozen_string_literal: true

# LegalGuardian Model
class LegalGuardian < ApplicationRecord
  before_save :normalize_phone

  has_many :users, dependent: :nullify

  validates :name, :surname, :email, :phone, :birth_day, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, types: [:fixed_or_mobile] }
  validate :an_eligible_legal_guardian?

  scope :by_name, ->(query) do
    if query.present?
      where(
        'legal_guardians.name LIKE :q OR legal_guardians.surname LIKE :q OR (legal_guardians.surname LIKE :s AND legal_guardians.name LIKE :n)',
        q: "%#{query}%",
        s: "%#{query.split.last}%",
        n: "%#{query.split.first}%"
      )
    end
  end

  scope :by_range, ->(range) do
    return unless range.present? && range.to_i.positive?

    joins(:users).group(:legal_guardian_id).having('COUNT(users.id) = ?', range.to_i)
  end

  scope :sorted, ->(sort_by, direction) do
    return unless %w[name surname birth_day email updated_at].include?(sort_by)

    direction = %w[asc desc].include?(direction) ? direction : 'asc'
    order("legal_guardians.#{sort_by} #{direction}")
  end

  def self.filter(params)
    lgs = all

    lgs = lgs.by_name(params[:name])
    lgs = lgs.by_range(params[:range])
    lgs = lgs.sorted(params[:sort_by], params[:direction] || 'desc')

    lgs
  end

  def full_name
    "#{name} #{surname}"
  end

  def minor?
    birth_day && age.years < 18.years
  end

  def age
    ((Time.zone.now - birth_day.to_time) / 1.year.seconds).floor
  end

  private

  def an_eligible_legal_guardian?
    return unless minor?

    errors.add(:birth_day, :too_young, message: I18n.t('global.errors.eligible'))
  end

  def normalize_phone
    self.phone = Phonelib.parse(phone).national
  end
end
