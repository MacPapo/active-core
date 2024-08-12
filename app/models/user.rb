class User < ApplicationRecord
  before_save :normalize_phone

  after_initialize :set_default_affiliated, if: :new_record?

  belongs_to :legal_guardian, optional: true

  has_one :staff      , dependent: :destroy
  has_one :membership , dependent: :destroy

  has_many :subscriptions         , dependent: :destroy
  has_many :subscription_payments , through: :subscriptions
  has_many :membership_payments   , through: :membership

  validates :cf, :name, :surname, :date_of_birth, presence: true
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
    self.date_of_birth && self.date_of_birth > 18.year.ago.to_date
  end

  def affiliated?
    self.affiliated
  end

  def get_date_of_birth
    self.date_of_birth.strftime('%d/%m/%Y')
  end

  def age
    ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
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
    is_membership_active?
  end

  def verify_compliance
    compliance = { status: true, errors: [] }

    if self.minor? && self.legal_guardian

      if self.med_cert_issue_date.nil? || (self.cf.nil? || self.cf.empty?)
        compliance[:status] = false

        compliance[:errors] << 'Certificato medico mancante' if self.med_cert_issue_date.nil?
        compliance[:errors] << 'Codice fiscale mancante' if self.cf.nil? || self.cf.empty?
      end

      return compliance
    end

    compliance[:status] = false unless self.email && self.phone && self.med_cert_issue_date

    compliance[:errors] << 'Codice fiscale mancante' if self.cf.nil? || self.cf.empty?
    compliance[:errors] << 'Email mancante' if self.email.nil? || self.email.empty?
    compliance[:errors] << 'Cellulare mancante' if self.phone.nil?
    compliance[:errors] << 'Certificato medico mancante' if self.med_cert_issue_date.nil?

    compliance
  end

  def verify_membership
    membership = self.membership

    status =
      case membership&.get_status
      when nil
        0
      when :inattivo
        1
      when :scaduto
        2
      when :attivo
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
      errors.add(:med_cert_issue_date, "can't be in the future!")
    end
  end

  def is_membership_active?
    self.membership && self.membership.get_status == :attivo
  end

  # TODO create a job that search all the users that are no longer minors and
  # have a legal_guardian attached and nullify the relation.
end
