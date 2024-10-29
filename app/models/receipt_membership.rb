# frozen_string_literal: true

# Receipt Membership Model
class ReceiptMembership < ApplicationRecord
  include Discard::Model

  belongs_to :receipt, dependent: :destroy
  belongs_to :membership
  belongs_to :user

  after_discard do
    receipt&.discard
    membership&.discard
  end

  after_undiscard do
    receipt&.undiscard
    membership&.undiscard
  end

  delegate :summary, to: :membership

  scope :for_fiscal_year, ->(year = Time.zone.today.year) do
    where(created_at: (Receipt.beginning_of_fiscal_year(year))..(Receipt.ending_of_fiscal_year(year)))
  end
end
