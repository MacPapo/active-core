# frozen_string_literal: true

# Receipts Controler
class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[show edit update destroy]

  # GET /receipts or /receipts.json
  def index
    @receipts = Receipt.all
  end

  # GET /receipts/1 or /receipts/1.json
  def show
    @pdf = generate_receipt

    respond_to do |format|
      format.pdf { send_pdf }
    end
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new
  end

  # GET /receipts/1/edit
  def edit; end

  # POST /receipts or /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: 'Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @receipt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1 or /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: 'Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1 or /receipts/1.json
  def destroy
    @receipt.discard

    # WATCH
    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: t('.delete_succ') }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_receipt
    @receipt =
      params[:payment_id].present? ? Receipt.find_by(payment_id: params[:payment_id]) : Receipt.find(params[:id])
  end

  def generate_receipt
    GenerateReceiptJob.perform_now(:print, @receipt)
  end

  def send_pdf
    send_data @pdf.render,
              filename: "#{@receipt.created_at.strftime('%s')}-ricevuta.pdf",
              type: 'application/pdf',
              disposition: :inline
  end

  # Only allow a list of trusted parameters through.
  def receipt_params
    params.require(:receipt).permit(:payment_id, :amount, :date, :staff_id)
  end
end
