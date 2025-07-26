# frozen_string_literal: true

# Generate Receipt Job
class GenerateReceiptJob < ApplicationJob
  queue_as :real_time

  # User op as :sym to handle event and payment to print or email
  def perform(*args)
    op, @receipt = args
    return nil if @receipt.blank?

    @entity = @receipt&.receipt_membership || @receipt&.receipt_subscription
    return nil if @entity.blank?

    handle_op(op)
  end

  private

  def handle_op(op)
    case op
    when :print
      generate_pdf
    when :email
      p "todo"
    else
      p "else"
    end
  end

  def generate_pdf
    Receipts::Receipt.new(
      page_size: Receipt::PAGE_SIZE,
      title: I18n.t("global.receipt.title"),
      details: generate_details,
      logo_height: 90,
      company: Receipt::COMPANY,
      recipient: generate_user_details,
      line_items: generate_line_items,
      footer: generate_footer
    )
  end

  def generate_details
    [
      [ I18n.t("global.receipt.date"), I18n.l(@receipt.date) ],
      [ I18n.t("global.receipt.number"), @entity.number ],
      [ I18n.t("global.receipt.method"), @receipt.payment.humanize_payment_method ]
    ]
  end

  def generate_user_details
    user = @entity.user
    [
      "<b>#{I18n.t('global.receipt.to')}</b>",
      user.cf,
      user.full_name,
      user.email,
      user.phone
    ]
  end

  def generate_line_items
    summary = @entity.summary
    amount  = @receipt.amount_to_currency
    [
      [ "<b>#{I18n.t('global.receipt.description')}</b>", "<b>#{I18n.t('global.receipt.amount')}</b>" ],
      [ summary, amount ]
    ]
  end

  def generate_footer
    I18n.t("global.receipt.footer")
  end
end
