# frozen_string_literal: true

# Payment Membership Model
class PaymentMembership < ApplicationRecord
  include Discard::Model

  belongs_to :payment, dependent: :destroy
  belongs_to :membership
  belongs_to :user

  after_discard do
    payment&.discard
    membership&.discard
  end

  after_undiscard do
    payment&.undiscard
    membership&.undiscard
  end
end
