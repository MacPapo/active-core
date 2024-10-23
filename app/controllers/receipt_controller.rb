# frozen_string_literal: true

# Receipt Controller
class ReceiptController < ApplicationController
  before_action :set_receipt, only: [:show, :destroy]

  def show
    @pdf = generate_receipt

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
end
