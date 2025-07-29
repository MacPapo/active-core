# frozen_string_literal: true

class Payment < ApplicationRecord
  include Discard::Model

  # Enums
  enum :payment_method, {
         cash: 0,
         card: 1,
         bank_transfer: 2,
         check: 3,
         digital_wallet: 4
       }, prefix: true

  # Associations
  belongs_to :user
  has_many :payment_items, dependent: :destroy
  has_many :payment_discounts, dependent: :destroy
  has_many :discounts, through: :payment_discounts
  has_one :receipt, dependent: :destroy

  # Through associations for polymorphic payables
  has_many :memberships, through: :payment_items, source: :payable, source_type: "Membership"
  has_many :package_purchases, through: :payment_items, source: :payable, source_type: "PackagePurchase"
  has_many :registrations, through: :payment_items, source: :payable, source_type: "Registration"

  # Validations
  validates :total_amount,
            presence: true,
            numericality: { greater_than: 0 }
  validates :discount_amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :final_amount,
            presence: true,
            numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :payment_method, presence: true
  validates :notes, length: { maximum: 1000 }, allow_blank: true

  # Custom validations
  validate :date_not_future
  validate :final_amount_calculation_correct
  validate :discount_not_greater_than_total
  validate :must_have_payment_items
  validate :income_payments_must_be_positive

  # Scopes
  scope :income, -> { where(income: true) }
  scope :expenses, -> { where(income: false) }
  scope :by_payment_method, ->(method) { where(payment_method: method) }
  scope :on_date, ->(date) { where(date: date) }
  scope :in_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :this_month, -> { where(date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :today, -> { where(date: Date.current) }
  scope :with_discounts, -> { joins(:payment_discounts) }
  scope :without_receipt, -> { left_joins(:receipt).where(receipts: { id: nil }) }
  scope :with_receipt, -> { joins(:receipt) }
  scope :by_amount_range, ->(min, max) { where(final_amount: min..max) }
  scope :recent, -> { order(date: :desc, created_at: :desc) }

  # Callbacks
  before_validation :calculate_final_amount
  before_validation :set_default_date
  after_create :update_daily_cash_report
  after_update :update_daily_cash_report, if: :saved_change_to_final_amount_or_date?
  after_discard :update_daily_cash_report

  # Instance methods
  def expense?
    !income?
  end

  def has_receipt?
    receipt.present?
  end

  def can_generate_receipt?
    income? && !has_receipt? && payment_items.exists?
  end

  def total_discount_amount
    payment_discounts.sum(:discount_amount)
  end

  def effective_discount_rate
    return 0 if total_amount.zero?
    (discount_amount / total_amount * 100).round(2)
  end

  def payment_summary
    items = payment_items.includes(:payable).map do |item|
      "#{item.payable_type}: #{item.description} (#{item.amount}€)"
    end
    items.join(", ")
  end

  def member_from_items
    # Get the member from the first membership, package_purchase, or registration
    payment_items.each do |item|
      case item.payable_type
      when "Membership"
        return item.payable.member
      when "PackagePurchase"
        return item.payable.member
      when "Registration"
        return item.payable.member
      end
    end
    nil
  end

  def add_item(payable, amount, description = nil)
    payment_items.build(
      payable: payable,
      amount: amount,
      description: description || default_description_for(payable)
    )
  end

  def add_discount(discount, discount_amount, notes = nil)
    payment_discounts.build(
      discount: discount,
      discount_amount: discount_amount,
      notes: notes
    )
    self.discount_amount = payment_discounts.sum(:discount_amount)
  end

  def remove_discount(discount)
    payment_discounts.where(discount: discount).destroy_all
    self.discount_amount = payment_discounts.sum(:discount_amount)
  end

  def apply_automatic_discounts(member)
    return unless member&.affiliated?

    # Find applicable discounts
    applicable_discounts = Discount.active.current.where(applicable_to: [ :all, :memberships, :packages ])

    applicable_discounts.each do |discount|
      next if payment_discounts.exists?(discount: discount)

      discount_amount = calculate_discount_amount(discount)
      next if discount_amount.zero?

      add_discount(discount, discount_amount, "Auto-applied")
    end

    calculate_final_amount
  end

  def generate_receipt_number
    return if has_receipt?

    year = date.year
    last_receipt = Receipt.where(year: year).maximum(:number) || 0
    next_number = last_receipt + 1

    Receipt.create!(
      payment: self,
      user: user,
      number: next_number,
      year: year,
      date: date
    )
  end

  def refund(refund_amount = nil, notes = nil)
    refund_amount ||= final_amount

    refund_payment = Payment.create!(
      user: user,
      total_amount: refund_amount,
      discount_amount: 0,
      final_amount: refund_amount,
      date: Date.current,
      payment_method: payment_method,
      income: false,
      notes: "Refund for Payment ##{id}#{notes ? " - #{notes}" : ""}"
    )

    # Create refund item
    refund_payment.payment_items.create!(
      payable: self,
      amount: refund_amount,
      description: "Refund for Payment ##{id}"
)

 refund_payment
 end

 # Class methods
 def self.total_revenue(start_date = nil, end_date = nil)
   scope = income
   scope = scope.in_date_range(start_date, end_date) if start_date && end_date
   scope.sum(:final_amount)
 end

 def self.total_expenses(start_date = nil, end_date = nil)
   scope = expenses
   scope = scope.in_date_range(start_date, end_date) if start_date && end_date
   scope.sum(:final_amount)
 end

 def self.revenue_by_payment_method(start_date = nil, end_date = nil)
   scope = income
   scope = scope.in_date_range(start_date, end_date) if start_date && end_date
   scope.group(:payment_method).sum(:final_amount)
 end

 def self.daily_revenue(date = Date.current)
   income.on_date(date).sum(:final_amount)
 end

 def self.monthly_revenue(month = Date.current.beginning_of_month)
   start_date = month.beginning_of_month
   end_date = month.end_of_month
   income.in_date_range(start_date, end_date).sum(:final_amount)
 end

 private

 def date_not_future
   return unless date.present?
   return if date <= Date.current

   errors.add(:date, "cannot be in the future")
 end

 def final_amount_calculation_correct
   return unless total_amount.present? && discount_amount.present? && final_amount.present?

   expected_final = total_amount - discount_amount
   return if (final_amount - expected_final).abs < 0.01 # Allow for rounding differences

   errors.add(:final_amount, "must equal total_amount minus discount_amount")
 end

 def discount_not_greater_than_total
   return unless total_amount.present? && discount_amount.present?
   return if discount_amount <= total_amount

   errors.add(:discount_amount, "cannot be greater than total amount")
 end

 def must_have_payment_items
   return if new_record? # Skip for new records as items might be added after creation
   return if payment_items.exists?

   errors.add(:base, "Payment must have at least one payment item")
 end

 def income_payments_must_be_positive
   return unless income? && final_amount.present?
   return if final_amount > 0

   errors.add(:final_amount, "must be positive for income payments")
 end

 def calculate_final_amount
   return unless total_amount.present?

   self.discount_amount ||= 0
   self.final_amount = total_amount - discount_amount
 end

 def set_default_date
   self.date ||= Date.current
 end

 def default_description_for(payable)
   case payable
   when Membership
     "Membership: #{payable.pricing_plan.product.name} (#{payable.pricing_plan.display_duration})"
   when PackagePurchase
     "Package: #{payable.package.name}"
   when Registration
     "Registration: #{payable.product.name}"
   else
     payable.class.name
   end
 end

 def calculate_discount_amount(discount)
   case discount.discount_type
   when "percentage"
     amount = (total_amount * discount.value / 100).round(2)
     discount.max_amount.present? ? [ amount, discount.max_amount ].min : amount
   when "fixed"
     [ discount.value, total_amount ].min
   else
     0
   end
 end

 def saved_change_to_final_amount_or_date?
   saved_change_to_final_amount? || saved_change_to_date?
 end

 def update_daily_cash_report
   DailyCashReportUpdateJob.perform_later(date) if date.present?
 end
end
