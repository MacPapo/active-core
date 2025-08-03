module Financial::RevenueAttribution
  extend ActiveSupport::Concern

  included do
    scope :revenue_generating, -> { joins(:payment).where(payments: { income: true }) }
    scope :this_month_revenue, -> { revenue_generating.joins(:payment).where(payments: { date: Date.current.all_month }) }
  end

  def generates_revenue?
    payment&.income? && amount&.positive?
  end

  def revenue_source
    return :none unless generates_revenue?

    case payable_type
    when "Membership" then :membership_fees
    when "Registration" then :course_fees
    when "PackagePurchase" then :package_sales
    else :other_revenue
    end
  end

  def monthly_recurring_value
    return 0 unless payable.respond_to?(:duration_in_days)
    return 0 if payable.duration_in_days.zero?

    (amount / payable.duration_in_days * 30).round(2)
  end

  def customer_lifetime_contribution
    return 0 unless payable_member

    PaymentItem.joins(:payment)
      .where(payments: { income: true })
      .for_member(payable_member)
      .sum(:amount)
  end
end
