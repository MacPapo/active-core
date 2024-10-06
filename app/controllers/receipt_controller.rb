# frozen_string_literal: true

# Receipt Controller
class ReceiptController < ApplicationController
  before_action :set_receipt, only: [:destroy]
  before_action :set_payment, only: [:show]

  def show
    respond_to do |format|
      format.pdf { send_pdf }
    end
  end

  # TODO
  def destroy
    @receipt.discard
    redirect_to users_path, notice: t('.delete_succ')
  end

  private

  def set_payment
    @payment = Payment.find(params[:payment_id])
  end

  def set_receipt
    @receipt = Receipt.find(params[:id])
  end

  def send_pdf
    receipt = GenerateReceiptJob.perform_now(:print, @payment)
    send_data receipt.render,
              filename: "#{@payment.created_at.strftime('%s')}-ricevuta.pdf",
              type: 'application/pdf',
              disposition: :inline
  end
end
