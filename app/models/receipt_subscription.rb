# frozen_string_literal: true

# Receipt Subscription Model
class ReceiptSubscription < ApplicationRecord
  include Discard::Model

  belongs_to :receipt, dependent: :destroy
  belongs_to :subscription
  belongs_to :user

  after_discard do
    receipt&.discard
    subscription&.discard
  end

  after_undiscard do
    receipt&.undiscard
    subscription&.undiscard
  end

  has_one :activity, through: :subscription

  delegate :summary, to: :subscription

  scope :for_fiscal_year, ->(year = Time.zone.today.year) do
    where(created_at: (Receipt.beginning_of_fiscal_year(year))..(Receipt.ending_of_fiscal_year(year)))
  end
end
