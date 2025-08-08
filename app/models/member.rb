# frozen_string_literal: true

# Member Model
class Member < ApplicationRecord
  include Discard::Model
  include Broadcastable

  # Associations
  has_one :user, dependent: :destroy

  has_many :access_grants, dependent: :restrict_with_error
  has_many :waitlists, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error

  # LegalGuardian
  belongs_to :legal_guardian, class_name: "Member", optional: true
  has_many :dependents, class_name: "Member", foreign_key: "legal_guardian_id", dependent: :nullify

  validates :first_name, :last_name, :birth_date, presence: true

  validates :tax_code, uniqueness: { case_sensitive: false, allow_blank: true, conditions: -> { kept } },
            format: { with: /\A[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST][0-9LMNPQRSTUV]{2}[A-Z][0-9LMNPQRSTUV]{3}[A-Z]\z/i,
                      message: "non è in un formato valido", allow_blank: true } # TODO LOCALIZE

  validates :email, uniqueness: { case_sensitive: false, allow_blank: true, conditions: -> { kept } },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "non è un'email valida", allow_blank: true }


  normalizes :first_name, with: -> { _1&.strip }
  normalizes :last_name, with: -> { _1&.strip }
  normalizes :tax_code, with: -> { _1&.upcase&.strip }
  normalizes :email, with: -> { _1&.downcase&.strip }

  # after_update -> { DetachLegalGuardiansJob.perform_later }, unless: :minor? TODO

  def full_name
    "#{first_name} #{last_name}".squish
  end

  def age
    return nil unless birth_date
    now = Time.now.utc.to_date
    now.year - birth_date.year - ((now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day)) ? 0 : 1)
  end

  def minor?
    age && age < 18
  end

  def staff?
    user.present? && user.kept?
  end

  def active_grants
    access_grants.active.where("start_date <= :today AND end_date >= :today", today: Date.current)
  end
end
