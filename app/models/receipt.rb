# frozen_string_literal: true

# Receipt Model
class Receipt < ApplicationRecord
  include Discard::Model

  belongs_to :payment, touch: true
  belongs_to :staff

  has_one :receipt_membership, dependent: :destroy
  has_one :receipt_subscription, dependent: :destroy

  has_one :muser, through: :receipt_membership, source: :user
  has_one :suser, through: :receipt_subscription, source: :user

  after_discard do
    receipt_membership&.discard
    receipt_subscription&.discard
  end

  after_undiscard do
    receipt_membership&.undiscard
    receipt_subscription&.undiscard
  end

  delegate :amount_to_currency, to: :payment

  BEGIN_FISCAL_YEAR = { day: 1, month: 1 }.freeze
  END_FISCAL_YEAR   = { day: 31, month: 12 }.freeze
  PAGE_SIZE = "A4"
  COMPANY = {
    name: "ASD Querini Fit",
    email: "asdquerinifit@gmail.com",
    phone: "+39 0413088379",
    address: "C. de le Capucine, 6576b",
    logo: Rails.root.join("app/assets/images/asd-querini.png")
  }.freeze

  def self.beginning_of_fiscal_year(year = Time.zone.today.year)
    Date.new(year, BEGIN_FISCAL_YEAR[:month], BEGIN_FISCAL_YEAR[:day])
  end

  def self.ending_of_fiscal_year(year = Time.zone.today.year + 1)
    Date.new(year, END_FISCAL_YEAR[:month], END_FISCAL_YEAR[:day])
  end
end
