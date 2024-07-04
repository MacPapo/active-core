class Staff < ApplicationRecord
  belongs_to :user

  has_many :subscription_histories, dependent: :nullify
  has_many :payments, dependent: :nullify

  validates :password, presence: true
  validates :role, inclusion: { in: %w[collaboratore volontario admin] }
end
