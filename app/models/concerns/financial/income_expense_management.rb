module Financial::IncomeExpenseManagement
  extend ActiveSupport::Concern

  included do
    scope :income, -> { where(income: true) }
    scope :expenses, -> { where(income: false) }
    scope :positive_income, -> { income.where("final_amount > ?", 0) }
    scope :major_expenses, -> { expenses.where("final_amount > ?", 100) }
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
    case
    when major_expense? then :major_expense
    when contributes_to_revenue? then :revenue
    when income? then :minor_income
    else :minor_expense
    end
  end
end
