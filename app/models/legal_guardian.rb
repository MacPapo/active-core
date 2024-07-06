class LegalGuardian < ApplicationRecord
  before_save :normalize_phone

  has_many :users, dependent: :nullify

  validates :name, :surname, :email, :phone, :date_of_birth, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is invalid' }
  validates :phone, phone: { possible: true, types: [:fixed_or_mobile] }
  validate :is_an_eligible_legal_guardian

  def full_name
    "#{self.name} #{self.surname}"
  end

  def minor?
    date_of_birth > 18.year.ago.to_date
  end

  private

  def is_an_eligible_legal_guardian
    if minor?
      errors.add(:legal_guardian, "must not be a minor!")
    end
  end

  def normalize_phone
    self.phone = Phonelib.parse(phone).full_e164.presence
  end
end
