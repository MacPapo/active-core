# frozen_string_literal: true

# Payment Subscription Model
class PaymentSubscription < ApplicationRecord
  # TODO
  include Discard::Model

  belongs_to :payment, dependent: :destroy
  belongs_to :subscription
  belongs_to :user

  has_one :activity, through: :subscription
end
