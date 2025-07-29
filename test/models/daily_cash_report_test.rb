require "test_helper"

class DailyCashReportTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    report = daily_cash_reports(:sample_report)
    assert report.valid?, report.errors.full_messages
  end

  test "should require report_date" do
    report = DailyCashReport.new
    assert_not report.valid?
    assert report.errors[:report_date].present?
  end

  test "should have unique report_date" do
    existing_report = daily_cash_reports(:sample_report)
    report = DailyCashReport.new(
      report_date: existing_report.report_date
    )
    assert_not report.valid?
    assert report.errors[:report_date].present?
  end

  test "should calculate totals correctly" do
    report = daily_cash_reports(:sample_report)
    total_payments = report.total_cash + report.total_card + report.total_bank_transfer
    assert_equal report.total_income, total_payments
    assert_equal report.net_total, report.total_income - report.total_expenses
  end

  test "should track various metrics" do
    report = daily_cash_reports(:sample_report)
    assert_equal 5, report.transaction_count
    assert_equal 2, report.membership_sales
    assert_equal 3, report.activity_registrations
    assert_equal 1, report.package_sales
  end
end
