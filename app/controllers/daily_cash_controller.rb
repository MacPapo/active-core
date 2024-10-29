# frozen_string_literal: true

# Daily Cash Controller
class DailyCashController < ApplicationController
  before_action :set_ordering, only: [:index]
  before_action :set_filters, only: [:index]

  # TODO fix filters
  def index
    @morning_item = Payment.daily_cash(:morning, @filters).includes(:staff)
    @afternoon_item = Payment.daily_cash(:afternoon, @filters).includes(:staff)

    @pagy_morning, @morning = pagy(@morning_item, page_param: :page_morning)
    @pagy_afternoon, @afternoon = pagy(@afternoon_item, page_param: :page_afternoon)

    @morning_cash = @morning_item.sum(:amount)
    @afternoon_cash = @afternoon_item.sum(:amount)

    @total = @morning_cash + @afternoon_cash
  end

  private

  def set_ordering
    @sort_by   = params[:sort_by]   || 'updated_at'
    @direction = params[:direction] || 'desc'
  end

  def set_filters
    @filters = {
      sort_by: @sort_by,
      direction: @direction
    }
  end
end
