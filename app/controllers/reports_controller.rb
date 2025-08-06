class ReportsController < ApplicationController
  def show
    # Se l'utente non specifica una data, usiamo quella di oggi
    @report_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @report = DailyReport.new(date: @report_date)
  end
end
