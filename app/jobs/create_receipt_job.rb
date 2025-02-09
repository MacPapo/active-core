# frozen_string_literal: true

# Create Receipt Job
class CreateReceiptJob < ApplicationJob
  queue_as :real_time

  def perform(*args)
    @type, @payment, eid = args
    return if @payment.present? && @payment.method != 'cash'

    @current_year = Time.zone.today.year
    ActiveRecord::Base.transaction do
      @receipt = generate_receipt
      @entity_receipt = receipt_handler(eid)
    end
  end

  private

  def generate_receipt
    Receipt.create(payment: @payment, staff: @payment.staff, date: @payment.date)
  end

  def receipt_handler(eid)
    return unless @type.present? && @receipt.present? && eid.present?

    case @type
    when 'mem'
      create_membership_receipt(eid)
    when 'sub'
      create_subscription_receipt(eid)
    else
      p 'LOG RHANDLER ELSE'
    end
  end

  def create_membership_receipt(eid)
    mem = Membership.find(eid)
    number = ReceiptMembership.for_fiscal_year.count + 1
    ReceiptMembership.create(receipt: @receipt, membership: mem, user: mem.user, year: @current_year, number:)
  end

  def create_subscription_receipt(eid)
    sub = Subscription.find(eid)
    number = ReceiptSubscription.for_fiscal_year.count + 1
    ReceiptSubscription.create(receipt: @receipt, subscription: sub, user: sub.user, year: @current_year, number:)
  end
end
