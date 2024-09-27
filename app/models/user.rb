# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  validates :name, :surname, presence: true
  validates :affiliated, inclusion: { in: [true, false] }

  validates :cf, length: { is: 16 }, allow_blank: true
  normalizes :cf, with: -> { _1.strip.upcase }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }
  validate :med_cert_issue_date_cannot_be_in_future, if: -> { med_cert_issue_date.present? }

  before_save :normalize_phone, if: -> { phone.present? }

  after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor?

  belongs_to :legal_guardian, optional: true

  has_one    :staff, dependent: :destroy
  has_one    :membership, dependent: :destroy

  has_many   :subscriptions, dependent: :destroy
  has_many   :waitlists, dependent: :destroy
  has_many   :receipts, dependent: :destroy

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
    if %w[name surname birth_day].include?(sort_by)
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

  def affiliated?
    affiliated
  end

  def age
    ((Time.zone.now - birth_day.to_time) / 1.year.seconds).floor
  end

  def med_cert_exp_date
    med_cert_issue_date.present? ? med_cert_issue_date + 1.year : nil
  end

  def num_of_days_til_med_cert_expire
    return -1 if med_cert_issue_date.nil?

    exp_date = med_cert_issue_date + 1.year
    (exp_date - Time.zone.today).to_i
  end

  def active_membership?
    membership&.active?
  end

  def verify_compliance
    avoid = %w[id cf affiliated legal_guardian_id created_at updated_at]
    avoid_minor = %w[email phone]

    attribute_names.map do |x|
      next if avoid.include?(x)

      val = send(x)
      next if avoid_minor.include?(x) && minor?

      next if val.present?

      User.human_attribute_name(x)
    end.compact
  end

  def med_cert_valid?
    return false if med_cert_issue_date.blank?

    Time.zone.today < med_cert_issue_date + 1.year
  end

  def has_open_subscription?
    return false if subscriptions.blank?

    subscriptions.each { |x| return true if x.open? }

    false
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).national
  end

  def med_cert_issue_date_cannot_be_in_future
    return unless med_cert_issue_date > Time.zone.today

    errors.add(:med_cert_issue_date, I18n.t('global.errors.med_date_future'))
  end
end
