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
        'name LIKE :q OR surname LIKE :q OR (surname LIKE :s AND name LIKE :n)',
        q: "%#{query}%",
        s: "%#{query.split.last}%",
        n: "%#{query.split.first}%"
      )
    end
  end

  scope :sorted, ->(sort_by, direction) do
    if %w[name surname birth_day email].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : 'asc'
      order("#{sort_by} #{direction}")
    end
  end

  scope :order_by_updated_at, -> { order('updated_at desc') }

  def self.filter(name, sort_by, direction)
    by_name(name)
      .sorted(sort_by, direction)
      .order_by_updated_at
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

    errors.add(:legal_guardian, 'must not be a minor!')
  end

  def normalize_phone
    self.phone = Phonelib.parse(phone).national
  end

  def delete_all_lg_without_users
    DeleteStaleLegalGuardiansJob.perform_later
  end
end
