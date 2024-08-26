# frozen_string_literal: true

# Receipt Controller
class ReceiptController < ApplicationController
  before_action :set_payment, only: [:show]

  def show
    respond_to do |format|
      format.pdf { send_pdf }
    end
  end

  private

  def set_payment
    @payment = Payment.find(params[:payment_id])
  end

  def send_pdf
    receipt = GenerateReceiptJob.perform_now(:sas, @payment)
    send_data receipt.render,
              filename: "#{@payment.created_at.strftime('%Y-%m-%d')}-ricevuta.pdf",
              type: 'application/pdf',
              disposition: :inline
  end
end
