# frozen_string_literal: true

# Daily Report Value Model
class DailyReport
  # Rendiamo leggibili i dati calcolati
  attr_reader :date, :payments, :total_income, :total_cash, :total_card,
              :total_bank_transfer, :plan_grants_sold, :package_grants_sold

  def initialize(date: Date.current)
    @date = date
    @payments = Payment.where(date: @date) # Grazie all'indice su 'date', questa query è velocissima

    calculate_totals
    count_grants_sold
  end

  private

  def calculate_totals
    # Il metodo `sum` è eseguito dal DB, è molto efficiente
    @total_income = @payments.where(income: true).sum(:final_amount)

    # Usiamo `group` per ottenere le somme per ogni metodo di pagamento in una sola query
    totals_by_method = @payments.where(income: true).group(:payment_method).sum(:final_amount)

    @total_cash = totals_by_method["cash"] || 0.0
    @total_card = totals_by_method["card"] || 0.0
    @total_bank_transfer = totals_by_method["bank_transfer"] || 0.0
  end

  def count_grants_sold
    grants_sold_today = AccessGrant.where(created_at: @date.all_day)

    @plan_grants_sold = grants_sold_today.where.not(pricing_plan_id: nil).count
    @package_grants_sold = grants_sold_today.where.not(package_id: nil).count
  end
end
