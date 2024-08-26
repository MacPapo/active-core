# frozen_string_literal: true

# Generate Receipt Job
class GenerateReceiptJob < ApplicationJob
  queue_as :real_time

  # User op as :sym to handle event and payment to retrieve Receipt or create it
  def perform(*args)
    op, payment = args

    receipt = Receipt.find_or_create_by(payment:) do |r|
      r.id = Receipt.generate_id
      r.date = payment.date
      r.amount = payment.amount
      r.cause = payment.payable_type
      r.user = User.first
    end

    generate_pdf(receipt)
  end

  private

  def generate_pdf(receipt)
    Receipts::Receipt.new(
      page_size: 'A4',
      title: 'Ricevuta',
      details: generate_details(receipt),
      logo_height: 90,
      company: receipt.company,
      recipient: generate_recipient(receipt.user),
      line_items: generate_line_items(receipt),
      footer: generate_footer
    )
  end

  def generate_details(receipt)
    [
      ['Ricevuta N: ', receipt.id.to_s],
      ['Data: ', I18n.l(receipt.date)],
      ['Metodo Pagamento', receipt.payment.humanize_payment_method]
    ]
  end

  def generate_recipient(user)
    [
      '<b>Ricevuta per</b>',
      user.cf,
      user.full_name,
      user.email,
      user.phone
    ]
  end

  def generate_line_items(receipt)
    [
      ['<b>Descrizione</b>', '<b>Costo</b>'],
      [receipt.payment.payment_summary, receipt.amount_to_currency]
    ]
  end

  def generate_footer
    'Grazie!'
  end
end
