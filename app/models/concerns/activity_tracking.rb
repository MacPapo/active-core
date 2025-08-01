module ActivityTracking
  extend ActiveSupport::Concern

  included do
    scope :active_today, -> {
      where(current_sign_in_at: Date.current.beginning_of_day..)
    }
    scope :by_activity_period, ->(from, to) {
      where(current_sign_in_at: from..to) if from && to
    }
  end

  def active_today?
    current_sign_in_at&.today?
  end

  def total_memberships_created
    memberships.count
  end

  def total_payments_processed
    payments.sum(:final_amount)
  end

  # TODO
  def productivity_score
    # Simple scoring system
    (total_memberships_created * 10) + (payments.count * 5)
  end
end
