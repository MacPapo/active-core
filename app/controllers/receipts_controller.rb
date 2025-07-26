class ReceiptsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!
  before_action :set_receipt, only: [ :show ]

  def index
    @receipts = Receipt.kept
                  .includes(:payment, :user)
                  .then { |receipts| apply_filters(receipts) }
                  .then { |receipts| apply_sorting(receipts) }
  end

  def show
    respond_to do |format|
      format.html
      format.pdf { send_data @receipt.to_pdf, filename: "ricevuta_#{@receipt.number}-#{@receipt.year}.pdf" }
    end
  end

  private

  def set_receipt
    @receipt = Receipt.kept.find(params[:id])
  end

  # Filterable methods
  def filterable_attributes
    {
      year: ->(scope, value) { scope.where(year: value) if value.present? },
      date_from: ->(scope, value) { scope.where("date >= ?", value) if value.present? },
      date_to: ->(scope, value) { scope.where("date <= ?", value) if value.present? }
    }
  end

  # Sortable methods
  def sortable_attributes
    { "number" => "receipts.number", "date" => "receipts.date" }
  end

  def default_sort
    { attribute: "number", direction: "desc" }
  end
end
