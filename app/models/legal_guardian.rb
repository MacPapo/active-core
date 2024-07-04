class LegalGuardian < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, :surname, :email, :phone, :date_of_birth, presence: true
end
