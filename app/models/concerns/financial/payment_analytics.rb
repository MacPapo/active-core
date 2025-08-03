module Financial::PaymentAnalytics
  extend ActiveSupport::Concern

  included do
    scope :high_value, -> { where("final_amount > ?", 100) }
    scope :by_staff_member, ->(user) { where(user: user) }
    scope :cash_payments, -> { where(payment_method: :cash) }
    scope :digital_payments, -> { where(payment_method: [ :card, :bank_transfer ]) }
  end

  def high_value_transaction?
    final_amount > 100
  end

  def payment_efficiency_score
    case payment_method
    when "card", "bank_transfer" then 10
    when "cash" then 7
    when "check" then 5
    else 1
    end
  end

  def transaction_age_in_days
    (Date.current - date).to_i
  end

  def belongs_to_current_month?
    date.all_month.cover?(Date.current)
  end

  def revenue_category
    return :membership if payment_items.joins(:payable).where(payable_type: "Membership").exists?
    return :packages if payment_items.joins(:payable).where(payable_type: "PackagePurchase").exists?
    return :courses if payment_items.joins(:payable).where(payable_type: "Registration").exists?
    :other
  end
end
