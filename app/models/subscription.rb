class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :subscription_type

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, dependent: :nullify
end
