class LegalGuardian < ApplicationRecord
  before_save :normalize_phone

  # after_save :delete_all_lg_without_users

  has_many :users, dependent: :nullify

  validates :name, :surname, :email, :phone, :birth_day, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, types: [:fixed_or_mobile] }
  validate :is_an_eligible_legal_guardian

  def full_name
    "#{self.name} #{self.surname}"
  end

  def minor?
    birth_day > 18.year.ago.to_date
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

  def delete_all_lg_without_users
    DeleteStaleLegalGuardiansJob.perform_later
  end
end
