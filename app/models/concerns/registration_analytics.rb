module RegistrationAnalytics
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { where(created_at: 1.month.ago..) }
    scope :popular_products, -> {
      joins(:product)
        .group("products.name")
        .order("COUNT(*) DESC")
    }
    scope :by_registration_period, ->(from, to) {
      where(created_at: from..to)
    }
  end

  def utilization_rate
    return 0 if unlimited_sessions? || !has_session_limit?

    initial_sessions = pricing_plan&.session_limit || sessions_remaining || 0
    return 0 if initial_sessions.zero?

    used_sessions = initial_sessions - (sessions_remaining || 0)
    (used_sessions.to_f / initial_sessions * 100).round(1)
  end

  def value_per_session
    return 0 if amount_paid.zero? || unlimited_sessions?

    total_sessions = pricing_plan&.session_limit || 1
    (amount_paid / total_sessions).round(2)
  end

  def registration_age_in_days
    (Date.current - created_at.to_date).to_i
  end

  def activity_level
    return :unlimited if unlimited_sessions?
    return :inactive if sessions_exhausted?
    return :active if sessions_remaining&.positive?
    :unknown
  end
end
