# frozen_string_literal: true

# Payment Controller
class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update destroy restore]
  before_action :set_ordering, only: [:index]
  before_action :set_filters, only: [:index]
  before_action :set_type_and_id, only: %i[new create]

  after_action :create_receipt, only: [:create], if: -> { @payment.persisted? }

  # GET /payments or /payments.json
  def index
    @pagy, @payments = pagy(
      Payment
        .filter(@filters)
        .includes(:staff, :receipt, :payment_membership, :payment_subscription)
        .load_async
    )
  end

  # GET /payments/1 or /payments/1.json
  def show; end

  # GET /payments/new
  def new
    @entity = find_entity(@type, @eid)
    @payment = @entity.blank? ? Payment.build : @entity.payments.build
    @payment.date = Time.zone.today
    @payment.amount = @entity.blank? ? 0.0 : @entity.cost
  end

  # GET /payments/1/edit
  def edit; end

  # POST /payments or /payments.json
  def create
    ActiveRecord::Base.transaction do
      @payment = Payment.create(payment_params)
      @entity_payment = payment_handler

      respond_to do |format|
        if @entity_payment.save
          format.html { redirect_to @payment, notice: t('.create_succ') }
          format.json { render :show, status: :created, location: @payment }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @payment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: t('.update_succ') }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    @payment.discard

    respond_to do |format|
      format.html { redirect_to payments_path, status: :see_other, notice: t('.destroy_succ') }
      format.json { head :no_content }
    end
  end

  def restore
    @payment.undiscard
    redirect_to payments_url, notice: t('.restore_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end

  def set_ordering
    @sort_by   = params[:sort_by]   || 'updated_at'
    @direction = params[:direction] || 'desc'
  end

  def set_type_and_id
    @type = params[:type]
    @eid  = params[:eid]
  end

  def payment_handler(eid = @eid, type = @type)
    return nil if eid.blank? && type.blank?

    case type
    when 'mem'
      mem = find_membership(eid)
      ActivateThingJob.perform_later(@type, mem.id)
      PaymentMembership.new(membership: mem, user: mem.user, payment: @payment)
    when 'sub'
      sub = find_subscription(eid)
      ActivateThingJob.perform_later(@type, sub.id)
      PaymentSubscription.new(subscription: sub, user: sub.user, payment: @payment)
    else
      p 'LOG PHANDLER ELSE'
    end
  end

  def create_receipt
    CreateReceiptJob.perform_later(@type, @payment, @eid)
  end

  def find_membership(id)
    Membership.find(id)
  end

  def find_subscription(id)
    Subscription.find(id)
  end

  def find_entity(type, id)
    return unless type.present? && %w[mem sub].include?(type)

    type == 'mem' ? find_membership(id) : find_subscription(id)
  end

  def set_filters
    @filters = {
      visibility: params[:visibility],
      name: params[:name],
      type: params[:payable_type],
      method: params[:payment_method],
      from: params[:date_from],
      to: params[:date_to],
      sort_by: @sort_by,
      direction: @direction
    }
  end

  # Only allow a list of trusted parameters through.
  def payment_params
    params.require(:payment).permit(:amount, :date, :method, :income, :note, :staff_id)
  end
end
