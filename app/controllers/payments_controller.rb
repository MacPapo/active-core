# frozen_string_literal: true

# Payment Controller
class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy]
  before_action :set_entity, only: %i[edit new]

  # GET /payments
  def index
    @pagy, @payments = pagy(
      Payment
        .filter(params[:date], params[:type], params[:method], params[:direction])
        .includes(:staff)
        .load_async
    )
  end

  # GET /payments/1
  def show; end

  # GET /payments/new
  def new
    @payment = @entity.nil? ? Payment.build : @entity.payments.build
    @payment.date = Time.zone.today
    @payment.amount = @entity.nil? ? 0.0 : @entity.cost
  end

  # GET /payments/1/edit
  def edit; end

  # POST /payments
  def create
    @payment = Payment.build(payment_params)

    if @payment.save
      redirect_to payment_url(@payment), notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payments/1
  def update
    if @payment.update(payment_params)
      redirect_to payment_url(@payment), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy!

    redirect_to payments_url, notice: t('.destroy_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  def set_entity
    @entity =
      case params[:payable_type]
      when 'Membership'
        Membership.find(params[:payable_id])
      when 'Subscription'
        Subscription.find(params[:payable_id])
      end
  end

  # Only allow a list of trusted parameters through.
  def payment_params
    params.require(:payment).permit(
      :amount, :date, :payment_method, :payable_type, :payable_id,
      :entry_type, :note, :subscription_id, :staff_id
    )
  end
end
