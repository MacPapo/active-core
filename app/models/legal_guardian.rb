# frozen_string_literal: true

# LegalGuardian Model
class LegalGuardian < ApplicationRecord
  # TODO rework
  before_save :normalize_phone

  # after_save :delete_all_lg_without_users

  has_many :users, dependent: :nullify

  validates :name, :surname, :email, :phone, :birth_day, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email, with: -> { _1.strip.downcase }

  validates :phone, phone: { possible: true, types: [:fixed_or_mobile] }
  validate :an_eligible_legal_guardian?

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
    self.phone = Phonelib.parse(phone).full_e164.presence
  end

  def delete_all_lg_without_users
    DeleteStaleLegalGuardiansJob.perform_later
  end
end
