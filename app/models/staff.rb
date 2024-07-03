class Staff < ApplicationRecord
  belongs_to :user

  validates :password, presence: true
  validates :role, inclusion: { in: %w[collaboratore volontario admin] }
end
