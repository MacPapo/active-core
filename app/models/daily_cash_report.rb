# frozen_string_literal: true

# DailyCashReport Model
class DailyCashReport < ApplicationRecord
  include PaymentAnalytics
  include RevenueAttribution

  validates :report_date, presence: true, uniqueness: true
  validates :total_cash, :total_card, :total_bank_transfer,
            :total_income, :total_expenses, :net_total,
            presence: true, numericality: true
  validates :transaction_count, :membership_sales,
            :activity_registrations, :package_sales,
            presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :for_month, ->(date) { where(report_date: date.beginning_of_month..date.end_of_month) }
  scope :for_year, ->(year) { where("strftime('%Y', report_date) = ?", year.to_s) }
  scope :recent, -> { order(report_date: :desc) }
  scope :profitable, -> { where("net_total > 0") }

  def self.generate_for_date(date = Date.current)
    existing = find_by(report_date: date)
    return existing if existing

    create!(
      report_date: date,
      **calculate_daily_totals(date)
    )
  end

  def profitable?
    net_total > 0
  end

  def payment_method_breakdown
    {
      cash: total_cash,
      card: total_card,
      bank_transfer: total_bank_transfer
    }
  end

  def sales_breakdown
    {
      memberships: membership_sales,
      activities: activity_registrations,
      packages: package_sales
    }
  end

  private

  def self.calculate_daily_totals(date)
    payments = Payment.kept.where(date: date)

    {
      total_cash: payments.where(payment_method: :cash).sum(:final_amount),
      total_card: payments.where(payment_method: :card).sum(:final_amount),
      total_bank_transfer: payments.where(payment_method: :bank_transfer).sum(:final_amount),
      total_income: payments.where(income: true).sum(:final_amount),
      total_expenses: payments.where(income: false).sum(:final_amount),
      net_total: payments.sum("CASE WHEN income THEN final_amount ELSE -final_amount END"),
      transaction_count: payments.count,
      membership_sales: count_sales_by_type(date, "Membership"),
      activity_registrations: count_sales_by_type(date, "Registration"),
      package_sales: count_sales_by_type(date, "PackagePurchase")
    }
  end

  def self.count_sales_by_type(date, payable_type)
    PaymentItem.joins(:payment)
      .where(payments: { date: date, income: true })
      .where(payable_type: payable_type)
      .count
  end
end
