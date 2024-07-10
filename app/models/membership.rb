class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_type

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify

  validates :date, presence: true
end
