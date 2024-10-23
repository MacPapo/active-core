# frozen_string_literal: true

# Payment Membership Model
class PaymentMembership < ApplicationRecord
  # TODO
  include Discard::Model

  belongs_to :payment, dependent: :destroy
  belongs_to :membership
  belongs_to :user
end
