module Member::RevenueTracking
  extend ActiveSupport::Concern

  def total_revenue
    membership_revenue + registration_revenue + package_revenue
  end

  private

  def membership_revenue
    Payment.joins(:payment_items)
      .where(payment_items: { payable_type: "Membership", payable_id: memberships.select(:id) })
      .sum(:final_amount)
  end

  def registration_revenue
    Payment.joins(:payment_items)
      .where(payment_items: { payable_type: "Registration", payable_id: registrations.select(:id) })
      .sum(:final_amount)
  end

  def package_revenue
    Payment.joins(:payment_items)
      .where(payment_items: { payable_type: "PackagePurchase", payable_id: package_purchases.select(:id) })
      .sum(:final_amount)
  end
end
