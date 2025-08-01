module Contactable
  extend ActiveSupport::Concern

  included do
    validates :email,
              format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true },
              uniqueness: { case_sensitive: false, allow_blank: true },
              allow_blank: true
    validates :phone, phone: { possible: true, allow_blank: true, types: [ :fixed_or_mobile ] }

    normalizes :email, with: -> { _1&.downcase&.strip }
    normalizes :phone, with: -> { Phonelib.parse(_1, :IT).national if _1.present? }

    scope :contactable, -> { where.not(email: [ nil, "" ]).or(where.not(phone: [ nil, "" ])) }
    scope :with_email, -> { where.not(email: [ nil, "" ]) }
    scope :with_phone, -> { where.not(phone: [ nil, "" ]) }
  end

  def contactable? = email.present? || phone.present?
  def primary_contact = email.presence || phone
end
