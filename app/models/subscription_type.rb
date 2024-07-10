class SubscriptionType < ApplicationRecord
  has_many :subscriptions

  enum plan: [:half, :one, :three, :year, :quota]

  validates :plan, presence: true
end
