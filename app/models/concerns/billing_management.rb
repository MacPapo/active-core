module BillingManagement
  extend ActiveSupport::Concern

  included do
    validates :billing_period_start, :billing_period_end, presence: true
    validates :billing_period_end, comparison: { greater_than: :billing_period_start }
    validates :amount_paid, comparison: { greater_than_or_equal_to: 0 }

    scope :billed_in_period, ->(from, to) {
      where(billing_period_start: from..to)
    }
    scope :by_amount_range, ->(min, max) { where(amount_paid: min..max) }
  end

  def billing_period_description
    "#{billing_period_start.strftime('%b %Y')} - #{billing_period_end.strftime('%b %Y')}"
  end

  def daily_cost
    (amount_paid / duration_in_days).round(2)
  end

  def monthly_equivalent
    (amount_paid / duration_in_days * 30).round(2)
  end

  def billing_matches_service_period?
    billing_period_start == start_date && billing_period_end == end_date
  end
end
