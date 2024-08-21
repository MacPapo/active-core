# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  before_save :normalize_phone

  # after_save :detach_lg_unless_minor, unless: :minor?

  belongs_to :legal_guardian, optional: true

  has_one    :staff, dependent: :destroy
  has_one    :membership, dependent: :destroy

  has_many   :subscriptions, dependent: :destroy
  has_many   :waitlists, dependent: :destroy

  attribute :cf, :string
  attribute :name, :string
  attribute :surname, :string
  attribute :affiliated, :boolean, default: false

  validates :name, :surname, presence: true
  validates :affiliated, inclusion: { in: [true, false] }

  validates :legal_guardian, presence: true, if: :minor?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }

  validate :med_cert_issue_date_cannot_be_in_future, if: :med_cert_present?

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

  def med_cert_present?
    med_cert_issue_date.present?
  end

  def med_cert_exp_date
    med_cert_present? ? med_cert_issue_date + 1.year : nil
  end

  def num_of_days_til_med_cert_expire
    return -1 if med_cert_issue_date.nil?

    exp_date = med_cert_issue_date + 1.year
    (exp_date - Time.zone.today).to_i
  end

  def active_membership?
    membership&.active?
  end

  # TODO rework this
  def verify_compliance
    compliance = { status: true, errors: [] }

    if self.minor? && self.legal_guardian

      if self.med_cert_issue_date.nil? || (self.cf.nil? || self.cf.empty?)
        compliance[:status] = false

        compliance[:errors] << I18n.t('global.errors.no_med') if self.med_cert_issue_date.nil?
      end

      return compliance
    end

    compliance[:status] = false unless self.email && self.phone && self.med_cert_issue_date

    compliance[:errors] << I18n.t('global.errors.no_email') if self.email.nil? || self.email.empty?
    compliance[:errors] << I18n.t('global.errors.no_phone') if self.phone.nil?
    compliance[:errors] << I18n.t('global.errors.no_med') if self.med_cert_issue_date.nil?

    compliance
  end

  def med_cert_valid?
    return false if med_cert_issue_date.blank?

    Time.zone.today < med_cert_issue_date + 1.year
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def med_cert_issue_date_cannot_be_in_future
    return unless med_cert_issue_date > Time.zone.today

    errors.add(:med_cert_issue_date, I18n.t('global.errors.med_date_future'))
  end

  def detach_lg_unless_minor
    DetachLegalGuardiansJob.perform_later
  end
end
