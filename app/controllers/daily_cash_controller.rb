# frozen_string_literal: true

# Daily Cash Controller
class DailyCashController < ApplicationController
  def index
    @morning_item = Payment.daily_cash(:morning).includes(:staff)
    @afternoon_item = Payment.daily_cash(:afternoon).includes(:staff)

    @pagy_morning, @morning = pagy(@morning_item, items: 5, page_param: :page_morning)
    @pagy_afternoon, @afternoon = pagy(@afternoon_item, items: 5, page_param: :page_afternoon)

    @morning_cash = @morning_item.sum(:amount)
    @afternoon_cash = @afternoon_item.sum(:amount)

    @total = @morning_cash + @afternoon_cash
  end
end
