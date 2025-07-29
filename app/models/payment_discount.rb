# frozen_string_literal: true

# PaymentDiscount Model
class PaymentDiscount < ApplicationRecord
  # Associations
  belongs_to :payment
  belongs_to :discount

  # Validations
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_id, uniqueness: {
    scope: :discount_id,
    message: "already has this discount applied"
  }

  # Scopes
  scope :by_discount, ->(discount) { where(discount: discount) }
  scope :by_payment, ->(payment) { where(payment: payment) }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_value, ->(threshold = 10) { where("discount_amount >= ?", threshold) }

  # Callbacks
  after_create :update_payment_discount_total
  after_update :update_payment_discount_total, if: :saved_change_to_discount_amount?
  after_destroy :update_payment_discount_total

  # Instance methods
  def discount_name
    discount.name
  end

  def discount_type_display
    discount.display_value
  end

  def formatted_amount
    "€#{discount_amount}"
  end

  def percentage_of_total
    return 0 if payment.total_amount.zero?
    (discount_amount / payment.total_amount * 100).round(2)
  end

  def applied_by
    payment.user.nickname
  end

  def applied_at
    created_at.strftime("%d/%m/%Y %H:%M")
  end

  private

  def update_payment_discount_total
    return unless payment&.persisted?

    # Recalculate total discount amount for the payment
    total_discounts = payment.payment_discounts.sum(:discount_amount)

    # Update without triggering callbacks to avoid infinite loops
    payment.update_column(:discount_amount, total_discounts)

    # Recalculate final amount
    final_amount = payment.total_amount - total_discounts
    payment.update_column(:final_amount, final_amount)
  end
end
