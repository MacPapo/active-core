class User < ApplicationRecord
  before_save :normalize_phone

  after_initialize :set_default_affiliated, if: :new_record?

  belongs_to :legal_guardian, optional: true

  has_one :staff, dependent: :destroy

  has_one :membership, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :payments, through: :subscriptions

  validates :cf, :name, :surname, :date_of_birth, presence: true
  validates :affiliated, inclusion: { in: [ true, false ] }
  validates :legal_guardian, presence: true, if: :minor?
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is invalid' }, allow_blank: true
  validates :phone, phone: { possible: true, allow_blank: true, types: [:fixed_or_mobile] }

  validate :med_cert_issue_date_cannot_be_in_future, if: :med_cert_present?

  def full_name
    "#{self.name} #{self.surname}"
  end

  def minor?
    date_of_birth > 18.year.ago.to_date
  end

  def med_cert_present?
    med_cert_issue_date.present?
  end

  def has_active_membership?
    is_membership_active?
  end

  def med_cert_valid?
    return false unless med_cert_issue_date.present?

    Date.today < med_cert_issue_date + 1.year
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
    membership && membership.state.to_sym == :attivo
  end
end
