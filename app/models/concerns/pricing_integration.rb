module PricingIntegration
  extend ActiveSupport::Concern

  included do
    scope :with_active_pricing, -> {
      joins(:pricing_plans).where(pricing_plans: { active: true })
    }
    scope :by_price_range, ->(min, max) {
      joins(:pricing_plans).where(pricing_plans: { price: min..max })
    }
  end

  def has_pricing?
    pricing_plans.active.exists?
  end

  def base_price
    pricing_plans.active.minimum(:price) || 0
  end

  def price_range
    prices = pricing_plans.active.pluck(:price)
    return "Free" if prices.empty?
    return "€#{prices.first}" if prices.size == 1
    "€#{prices.min} - €#{prices.max}"
  end

  def available_durations
    pricing_plans.active.pluck(:duration_type, :duration_value)
      .map { |type, value| "#{value} #{type.pluralize}" }
  end

  def total_revenue
    registration_ids = registrations.pluck(:id)

    Payment.joins(:payment_items)
      .where(payment_items: {
               payable_type: "Registration",
               payable_id: registration_ids
             })
      .sum(:final_amount)
  end
end
