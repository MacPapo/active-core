# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  validates :name, :surname, presence: true
  validates :affiliated, inclusion: { in: [true, false] }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }
  validate :med_cert_issue_date_cannot_be_in_future, if: -> { med_cert_issue_date.present? }

  before_save :normalize_phone

  after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor?

  belongs_to :legal_guardian, optional: true

  has_one    :staff, dependent: :destroy
  has_one    :membership, dependent: :destroy

  has_many   :subscriptions, dependent: :destroy
  has_many   :waitlists, dependent: :destroy
  has_many   :receipts, dependent: :destroy

  scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") if name.present? }
  scope :by_surname, ->(surname) { where('surname LIKE ?', "%#{surname}%") if surname.present? }
  scope :order_by_updated_at, ->(direction) { order("updated_at #{direction.blank? ? 'DESC' : direction.upcase}") }

  def self.filter(name, surname, direction)
    by_name(name).by_surname(surname).order_by_updated_at(direction)
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
    (attribute_names - %w[id cf affiliated legal_guardian_id created_at updated_at]).map do |x|
      val = send(x)
      next if val.present?

      I18n.t("global.errors.no_#{x}")
    end.compact
  end

  def med_cert_valid?
    return false if med_cert_issue_date.blank?

    Time.zone.today < med_cert_issue_date + 1.year
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
