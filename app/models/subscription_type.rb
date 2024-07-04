class SubscriptionType < ApplicationRecord
  has_many :subscriptions

  validates :desc, :duration, :cost, presence: true
end
