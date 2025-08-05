module Financial::BillingManagement
  extend ActiveSupport::Concern

  included do
    validates :billing_period_start, :billing_period_end, presence: true
    validates :billing_period_end, comparison: { greater_than: :billing_period_start }

    scope :billed_in_period, ->(from, to) { where(billing_period_start: from..to) }
    scope :by_amount_range, ->(min, max) { joins(payment_items: :payment).where(payments: { final_amount: min..max }) }
  end

  def billing_period_description
    "#{I18n.l(billing_period_start, format: :short)} - #{I18n.l(billing_period_end, format: :short)}"
  end

  def daily_cost
    paid_amount = payments.sum(:final_amount)
    return 0 if duration_in_days.to_i.zero?
    (paid_amount.to_f / duration_in_days).round(2)
  end

  def monthly_equivalent
    (daily_cost * 30).round(2)
  end

  def billing_matches_service_period?
    billing_period_start == start_date && billing_period_end == end_date
  end
end
