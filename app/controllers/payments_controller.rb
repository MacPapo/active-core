# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!
  before_action :set_payment, only: [ :show ]

  def index
    @payments = Payment.kept
                  .includes(:user, :receipts)
                  .then { |payments| apply_filters(payments) }
                  .then { |payments| apply_sorting(payments) }
  end

  def show; end

  def new
    @payment = Payment.new
    @payment.payment_items.build
  end

  def create
    @payment = Payment.new(payment_params.merge(user: current_user))

    if @payment.save
      redirect_to @payment, notice: "Pagamento registrato con successo."
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_payment
    @payment = Payment.kept.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:total_amount, :date, :payment_method, :income, :notes,
                                    payment_items_attributes: [ :amount, :description ])
  end
end
