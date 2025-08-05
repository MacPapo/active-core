# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  include Discard::Model
  include Discount::Integration
  include Financial::Receiptable, Financial::Transaction, Financial::IncomeExpenseManagement, Financial::PaymentAnalytics

  # Associations
  belongs_to :user
  has_many :payment_items, dependent: :destroy
  has_many :payment_discounts, dependent: :destroy
  has_many :discounts, through: :payment_discounts
  has_many :receipts, dependent: :destroy

  # Polymorphic associations through payment_items
  has_many :memberships, through: :payment_items, source: :payable, source_type: "Membership"
  has_many :registrations, through: :payment_items, source: :payable, source_type: "Registration"
  has_many :package_purchases, through: :payment_items, source: :payable, source_type: "PackagePurchase"

  # Validations
  validates :payment_items, presence: true
  validate :final_amount_matches_calculation
  validate :discount_amount_not_exceeding_total

  # Callbacks
  before_save :ensure_amounts_consistency
  after_create :generate_receipt_if_income
  # after_update :update_daily_cash_report TODO

  # Business logic scopes
  scope :needs_receipt, -> { income.left_joins(:receipts).where(receipts: { id: nil }) }
  scope :processed_by, ->(user) { where(user: user) }

  def self.daily_summary(date = Date.current)
    where(date: date).group(:payment_method, :income)
      .sum(:final_amount)
  end

  def display_summary
    items_summary = payment_items.map(&:description).compact.join(", ")
    "€#{final_amount} - #{items_summary}"
  end

  def requires_receipt?
    income? && final_amount > 0
  end

  private

  def final_amount_matches_calculation
    return unless total_amount && discount_amount && final_amount

    expected_final = total_amount - discount_amount
    errors.add(:final_amount, "doesn't match calculation") unless final_amount == expected_final
  end

  def discount_amount_not_exceeding_total
    return unless total_amount && discount_amount

    errors.add(:discount_amount, "cannot exceed total amount") if discount_amount > total_amount
  end

  def ensure_amounts_consistency
    self.total_amount = payment_items.sum(:amount)
    self.discount_amount = payment_discounts.sum(:discount_amount)
    self.final_amount = total_amount - discount_amount
  end

  def generate_receipt_if_income
    receipts.create!(user: user, date: date) if requires_receipt?
  end

  def update_daily_cash_report
    DailyCashReportUpdateJob.perform_later(date) if saved_change_to_final_amount?
  end
end
