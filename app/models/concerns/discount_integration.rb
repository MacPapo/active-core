module DiscountIntegration
  extend ActiveSupport::Concern

  included do
    scope :with_discounts, -> { joins(:payment_discounts) }
    scope :without_discounts, -> { where(discount_amount: 0) }
    scope :heavily_discounted, -> { where("discount_amount > total_amount * 0.2") }
  end

  def has_applied_discounts?
    payment_discounts.exists?
  end

  def applied_discounts_count
    payment_discounts.count
  end

  def total_discount_applied
    payment_discounts.sum(:discount_amount)
  end

  def discounts_summary
    payment_discounts.joins(:discount)
      .pluck("discounts.name", :discount_amount)
      .map { |name, amount| "#{name}: €#{amount}" }
      .join(", ")
  end

  def heavily_discounted?
    has_discount? && discount_amount > (total_amount * 0.2)
  end

  def apply_discount!(discount, custom_amount: nil)
    return false unless discount.active?

    discount_amount = custom_amount || calculate_discount_amount(discount)

    payment_discounts.create!(
      discount: discount,
      discount_amount: discount_amount
    )

    recalculate_totals!
  end

  private

  def calculate_discount_amount(discount)
    case discount.discount_type
    when "percentage"
      amount = (total_amount * discount.value / 100)
      discount.max_amount ? [ amount, discount.max_amount ].min : amount
    when "fixed_amount"
      [ discount.value, total_amount ].min
    else
      0
    end
  end

  def recalculate_totals!
    self.discount_amount = total_discount_applied
    self.final_amount = total_amount - discount_amount
    save!
  end
end
