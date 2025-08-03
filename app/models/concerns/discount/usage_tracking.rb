module Discount::UsageTracking
  extend ActiveSupport::Concern

  included do
    scope :frequently_used, -> { joins(:payment_discounts).group(:id).having("COUNT(payment_discounts.id) >= 5") }
    scope :unused, -> { left_outer_joins(:payment_discounts).where(payment_discounts: { id: nil }) }
    scope :high_value_discounts, -> { joins(:payment_discounts).where("payment_discounts.discount_amount >= 20") }
  end

  def usage_count
    payment_discounts.size
  end

  def total_discount_given
    payment_discounts.sum(:discount_amount)
  end

  def average_discount_amount
    return 0 if usage_count.zero?
    (total_discount_given.to_f / usage_count).round(2)
  end

  def frequently_used?
    usage_count >= 5
  end

  def high_impact_discount?
    total_discount_given >= 100
  end

  def usage_trend
    recent_usage = payment_discounts.joins(:payment).where(payments: { date: 1.month.ago.. }).count

    case
    when recent_usage > usage_count * 0.3 then :trending_up
    when recent_usage < usage_count * 0.1 then :trending_down
    else :stable
    end
  end

  def last_used_date
    payment_discounts.joins(:payment).maximum("payments.date")
  end

  def days_since_last_use
    return Float::INFINITY unless last_used_date
    (Date.current - last_used_date).to_i
  end
end
