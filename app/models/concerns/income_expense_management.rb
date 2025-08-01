module IncomeExpenseManagement
  extend ActiveSupport::Concern

  included do
    scope :income, -> { where(income: true) }
    scope :expenses, -> { where(income: false) }
    scope :profitable, -> { income.where("final_amount > ?", 0) }
    scope :costly, -> { expenses.where("final_amount > ?", 100) }
  end

  def income?
    income
  end

  def expense?
    !income
  end

  def contributes_to_revenue?
    income? && final_amount.positive?
  end

  def major_expense?
    expense? && final_amount > 100
  end

  def financial_impact
    multiplier = income? ? 1 : -1
    final_amount * multiplier
  end

  def cash_flow_category
    return :revenue if income? && final_amount > 50
    return :minor_income if income?
    return :major_expense if expense? && final_amount > 100
    :minor_expense
  end
end
