module Registration::Analytics
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { where(created_at: 1.month.ago..) }
    scope :popular_products, -> { joins(:product).group("products.id, products.name").order("COUNT(*) DESC") }
    scope :by_registration_period, ->(from, to) { where(created_at: from..to) }
  end

  def utilization_rate
    return 100.0 if unlimited_sessions?
    return 0 unless has_session_limit? && sessions_remaining

    initial_sessions = pricing_plan&.session_limit || sessions_remaining
    return 0 if initial_sessions.zero?

    used_sessions = initial_sessions - sessions_remaining
    (used_sessions.to_f / initial_sessions * 100).round(1)
  end

  def cost_per_session
    paid_amount = payments.sum(:final_amount)

    return 0 if paid_amount.zero? || unlimited_sessions? || total_sessions.zero?

    (paid_amount.to_f / total_sessions).round(2)
  end
  def registration_age_in_days
    (Date.current - created_at.to_date).to_i
  end

  def activity_level
    case
    when unlimited_sessions? then :unlimited
    when sessions_exhausted? then :inactive
    when sessions_remaining&.positive? then :active
    else :unknown
    end
  end
end
