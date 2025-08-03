# frozen_string_literal: true

# PaymentDiscount Model
class PaymentDiscount < ApplicationRecord
  belongs_to :payment
  belongs_to :discount

  validates :discount_amount, numericality: { greater_than: 0, presence: true }
  validates :payment_id, uniqueness: { scope: :discount_id }
  validate :discount_amount_within_limits
  validate :discount_is_applicable

  scope :for_payment, ->(payment) { where(payment: payment) }
  scope :for_discount, ->(discount) { where(discount: discount) }
  scope :this_month, -> { joins(:payment).where(payments: { date: Date.current.beginning_of_month.. }) }

  def discount_percentage
    return 0 if payment.total_amount.zero?
    (discount_amount / payment.total_amount * 100).round(2)
  end

  private

  def discount_amount_within_limits
    return unless discount&.max_amount && discount_amount

    errors.add(:discount_amount, "exceeds maximum limit") if discount_amount > discount.max_amount
  end

  def discount_is_applicable
    return unless discount

    errors.add(:discount, "is not active") unless discount.active?
    errors.add(:discount, "is not currently valid") unless discount.currently_valid?
  end
end
