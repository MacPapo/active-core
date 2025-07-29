# frozen_string_literal: true

# PaymentItem Model
class PaymentItem < ApplicationRecord
  include Discard::Model

  # Associations
  belongs_to :payment
  belongs_to :payable, polymorphic: true

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payable_type, inclusion: {
    in: %w[Membership Registration PackagePurchase],
    message: "must be a valid payable type"
  }

  # Scopes
  scope :for_memberships, -> { where(payable_type: "Membership") }
  scope :for_registrations, -> { where(payable_type: "Registration") }
  scope :for_packages, -> { where(payable_type: "PackagePurchase") }
  scope :by_amount, ->(amount) { where(amount: amount) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :update_payment_total
  after_update :update_payment_total, if: :saved_change_to_amount?
  after_destroy :update_payment_total

  # Instance methods
  def payable_name
    case payable_type
    when "Membership"
      "Membership - #{payable.pricing_plan.product.name}"
    when "Registration"
      "Registration - #{payable.product.name}"
    when "PackagePurchase"
      "Package - #{payable.package.name}"
    else
      payable_type
    end
  end

  def member_name
    case payable_type
    when "Membership", "Registration", "PackagePurchase"
      "#{payable.member.name} #{payable.member.surname}"
    else
      "Unknown"
    end
  end

  def formatted_amount
    "€#{amount}"
  end

  def duration_info
    return nil unless payable.respond_to?(:start_date) && payable.respond_to?(:end_date)

    "#{payable.start_date.strftime('%d/%m/%Y')} - #{payable.end_date.strftime('%d/%m/%Y')}"
  end

  private

  def update_payment_total
    return unless payment&.persisted?

    # Recalculate payment total based on current payment items
    new_total = payment.payment_items.kept.sum(:amount)

    # Update without triggering callbacks to avoid infinite loops
    payment.update_column(:total_amount, new_total)

    # Recalculate final amount considering discounts
    final_amount = new_total - payment.discount_amount
    payment.update_column(:final_amount, final_amount)
  end
end
