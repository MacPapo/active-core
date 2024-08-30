# frozen_string_literal: true

# Daily Cash Controller
class DailyCashController < ApplicationController
  def index
    @morning_pagy, @morning = pagy(
      Payment.daily_cash(:morning).includes(:staff)
    )
    @afternoon_pagy, @afternoon = pagy(
      Payment.daily_cash(:afternoon).includes(:staff)
    )

    @morning_cash = @morning.sum(:amount)
    @afternoon_cash = @afternoon.sum(:amount)

    @total = @morning_cash + @afternoon_cash
  end
end
