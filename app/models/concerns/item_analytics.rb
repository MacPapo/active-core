module ItemAnalytics
  extend ActiveSupport::Concern

  included do
    scope :popular_services, -> {
      group(:payable_type)
        .order("COUNT(*) DESC")
        .count
    }
    scope :high_value_items, -> { where(amount: 100..) }
  end

  def item_performance_score
    score = 0
    score += 10 if expensive_item?
    score += 5 if generates_revenue?
    score += 3 if links_to_active_service?
    score += 2 if contributes_significantly?
    score
  end

  def service_utilization_rate
    return 0 unless payable.respond_to?(:utilization_rate)
    payable.utilization_rate
  end

  def days_since_purchase
    return 0 unless payment&.date
    (Date.current - payment.date).to_i
  end

  def payment_recency_category
    days = days_since_purchase
    case days
    when 0..7 then :recent
    when 8..30 then :current_month
    when 31..90 then :recent_quarter
    else :historical
    end
  end
end
