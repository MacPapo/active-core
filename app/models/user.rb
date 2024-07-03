class User < ApplicationRecord
  belongs_to :legal_guardian, optional: true
  has_one :staff, dependent: :destroy

  validates :name, :surname, :date_of_birth, presence: true
end
