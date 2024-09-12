# frozen_string_literal: true

# Generate Receipt Job
class GenerateReceiptJob < ApplicationJob
  queue_as :real_time

  # User op as :sym to handle event and payment to print or email
  def perform(*args)
    op, payment = args

    receipt = generate_receipt(payment)

    handle_op(op, receipt)
  end

  private

  def handle_op(op, receipt)
    case op
    when :print
      generate_pdf(receipt)
    when :email
      p 'todo'
    else
      p 'else'
    end
  end

  def generate_receipt(payment)
    sub, mem = Receipt.generate_number(payment.date, payment.payable_type)

    Receipt.find_or_create_by(payment:) do |r|
      r.sub_num = sub
      r.mem_num = mem
      r.date = payment.date
      r.amount = payment.amount
      r.cause = payment.payable_type
      r.user = payment.user
    end
  end

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
    num = receipt.cause == 'Membership' ? receipt.mem_num : receipt.sub_num

    [
      ['Ricevuta N: ', num],
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
