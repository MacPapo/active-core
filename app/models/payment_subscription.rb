# frozen_string_literal: true

# Payment Subscription Model
class PaymentSubscription < ApplicationRecord
  include Discard::Model

  belongs_to :payment, dependent: :destroy
  belongs_to :subscription
  belongs_to :user

  has_one :activity, through: :subscription

  after_discard do
    payment&.discard
    subscription&.discard
  end

  after_undiscard do
    payment&.undiscard
    subscription&.undiscard
  end
end
