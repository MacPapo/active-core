module Discount::Integration
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
    heavily_discounted?.exists?(self.id)
  end

  def apply_discount!(discount, custom_amount: nil)
    return false unless discount.active?
    return false unless compatible_with_existing_discounts?(discount)

    discount_amount = custom_amount || discount.calculate_discount_for(total_amount)

    payment_discounts.create!(
      discount: discount,
      discount_amount: discount_amount
    )

    recalculate_totals!
    true
  end

  private

  def compatible_with_existing_discounts?(new_discount)
    payment_discounts.each do |applied_discount|
      return false unless applied_discount.discount.compatible_with?(new_discount)
    end
    true
  end

  def recalculate_totals!
    self.discount_amount = payment_discounts.sum(:discount_amount)
    self.final_amount = total_amount - discount_amount
    save!
  end
end
