class User < ApplicationRecord
  before_save :normalize_phone

  belongs_to :legal_guardian, optional: true
  has_one :staff, dependent: :destroy

  validates :name, :surname, :date_of_birth, presence: true
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

  def med_cert_valid?
    return false unless med_cert_issue_date.present?

    Date.today < med_cert_issue_date + 1.year
  end

  private

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def med_cert_issue_date_cannot_be_in_future
    if med_cert_issue_date > Date.today
      errors.add(:med_cert_issue_date, "can't be in the future!")
    end
  end
end
