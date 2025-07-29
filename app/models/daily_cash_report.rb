# frozen_string_literal: true

# DailyCashReport Model
class DailyCashReport < ApplicationRecord
  # Validations
  validates :report_date, presence: true, uniqueness: true
  validates :total_cash, :total_card, :total_bank_transfer, :total_income,
            :total_expenses, :net_total, presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_count, :membership_sales, :activity_registrations,
            :package_sales, presence: true,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Scopes
  scope :for_date, ->(date) { where(report_date: date) }
  scope :for_month, ->(month, year = Date.current.year) {
    where('strftime("%m", report_date) = ? AND strftime("%Y", report_date) = ?',
          month.to_s.rjust(2, "0"), year.to_s)
  }
  scope :for_year, ->(year) { where('strftime("%Y", report_date) = ?', year.to_s) }
  scope :date_range, ->(start_date, end_date) { where(report_date: start_date..end_date) }
  scope :recent, -> { order(report_date: :desc) }
  scope :profitable, -> { where("net_total > 0") }
  scope :with_losses, -> { where("net_total < 0") }

  # Class methods for report generation
  def self.generate_for_date(date = Date.current)
    return find_by(report_date: date) if exists?(report_date: date)

    payments = Payment.kept.where(date: date)

    # Calculate totals by payment method
    cash_total = payments.where(payment_method: :cash).sum(:final_amount)
    card_total = payments.where(payment_method: :card).sum(:final_amount)
    bank_transfer_total = payments.where(payment_method: :bank_transfer).sum(:final_amount)

    # Separate income and expenses
    income_payments = payments.where(income: true)
    expense_payments = payments.where(income: false)

    total_income = income_payments.sum(:final_amount)
    total_expenses = expense_payments.sum(:final_amount)
    net_total = total_income - total_expenses

    # Count different types of sales
    membership_count = count_memberships_for_date(date)
    activity_count = count_activities_for_date(date)
    package_count = count_packages_for_date(date)

    create!(
      report_date: date,
      total_cash: cash_total,
      total_card: card_total,
      total_bank_transfer: bank_transfer_total,
      total_income: total_income,
      total_expenses: total_expenses,
      net_total: net_total,
      transaction_count: payments.count,
      membership_sales: membership_count,
      activity_registrations: activity_count,
      package_sales: package_count
    )
  end

  def self.regenerate_for_date(date)
    existing = find_by(report_date: date)
    existing&.destroy
    generate_for_date(date)
  end

  def self.monthly_summary(month, year = Date.current.year)
    reports = for_month(month, year)

    {
      total_days: reports.count,
      total_cash: reports.sum(:total_cash),
      total_card: reports.sum(:total_card),
      total_bank_transfer: reports.sum(:total_bank_transfer),
      total_income: reports.sum(:total_income),
      total_expenses: reports.sum(:total_expenses),
      net_total: reports.sum(:net_total),
      total_transactions: reports.sum(:transaction_count),
      total_memberships: reports.sum(:membership_sales),
      total_activities: reports.sum(:activity_registrations),
      total_packages: reports.sum(:package_sales),
      average_daily_income: reports.average(:total_income)&.round(2) || 0,
      best_day: reports.maximum(:net_total) || 0,
      worst_day: reports.minimum(:net_total) || 0
    }
  end

  # Instance methods
  def total_revenue
    total_cash + total_card + total_bank_transfer
  end

  def formatted_date
    report_date.strftime("%d/%m/%Y")
  end

  def profit_margin
    return 0 if total_income.zero?
    ((net_total / total_income) * 100).round(2)
  end

  def average_transaction_value
    return 0 if transaction_count.zero?
    (total_income / transaction_count).round(2)
  end

  def payment_method_breakdown
    total = total_revenue
    return {} if total.zero?

    {
      cash: ((total_cash / total) * 100).round(2),
      card: ((total_card / total) * 100).round(2),
      bank_transfer: ((total_bank_transfer / total) * 100).round(2)
    }
  end

  def sales_breakdown
    total_sales = membership_sales + activity_registrations + package_sales
    return {} if total_sales.zero?

    {
      memberships: ((membership_sales.to_f / total_sales) * 100).round(2),
      activities: ((activity_registrations.to_f / total_sales) * 100).round(2),
      packages: ((package_sales.to_f / total_sales) * 100).round(2)
    }
  end

  def profitable?
    net_total > 0
  end

  def formatted_net_total
    sign = net_total >= 0 ? "+" : ""
    "#{sign}€#{net_total}"
  end

  private

  def self.count_memberships_for_date(date)
    PaymentItem.kept
               .joins(:payment)
               .where(payments: { date: date, income: true })
               .where(payable_type: "Membership")
               .count
  end

  def self.count_activities_for_date(date)
    PaymentItem.kept
               .joins(:payment)
               .where(payments: { date: date, income: true })
               .where(payable_type: "Registration")
               .count
  end

  def self.count_packages_for_date(date)
    PaymentItem.kept
               .joins(:payment)
               .where(payments: { date: date, income: true })
               .where(payable_type: "PackagePurchase")
               .count
  end
end
