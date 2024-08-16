class User < ApplicationRecord
  before_save :normalize_phone

  after_initialize :set_default_affiliated, if: :new_record?

  # after_save :detach_lg_unless_minor, unless: :minor?

  belongs_to :legal_guardian, optional: true

  has_one :staff      , dependent: :destroy
  has_one :membership , dependent: :destroy

  has_many :subscriptions         , dependent: :destroy

  validates :cf, :name, :surname, :birth_day, presence: true
  validates :affiliated, inclusion: { in: [ true, false ] }

  validates :legal_guardian, presence: true, if: :minor?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }

  validate :med_cert_issue_date_cannot_be_in_future, if: :med_cert_present?

  def full_name
    "#{self.name} #{self.surname}"
  end

  def minor?
    self.birth_day && self.birth_day > 18.year.ago.to_date
  end

  def affiliated?
    self.affiliated
  end

  def age
    ((Time.zone.now - birth_day.to_time) / 1.year.seconds).floor
  end

  def med_cert_present?
    med_cert_issue_date.present?
  end

  def get_num_of_days_til_med_cert_expire
    return -1 if med_cert_issue_date.nil?

    exp_date = med_cert_issue_date + 1.year
    (exp_date - Date.today).to_i
  end

  def has_active_membership?
    self.membership&.active?
  end

  def verify_compliance
    # TODO rework this
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

  def verify_membership
    membership = self.membership

    status =
      case membership&.get_status
      when nil
        0
      when :inactive
        1
      when :expired
        2
      when :active
        3
      else
        p membership.get_status
        -1
      end

    {
      status: ,
      days_til_renewal: self.membership.nil? ? nil : self.membership.get_num_of_days_til_renewal
    }
  end

  def med_cert_valid?
    return false unless med_cert_issue_date.present?

    Date.today < med_cert_issue_date + 1.year
  end

  def is_affiliated?
    self.affiliated
  end

  private

  def set_default_affiliated
    self.affiliated ||= false
  end

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def med_cert_issue_date_cannot_be_in_future
    if med_cert_issue_date > Date.today
      errors.add(:med_cert_issue_date, I18n.t('global.errors.med_date_future'))
    end
  end

  def detach_lg_unless_minor
    DetachLegalGuardiansJob.perform_later
  end
end
