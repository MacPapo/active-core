# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  # TODO
  include Discard::Model

  belongs_to :staff

  has_one :payment_membership, dependent: :destroy
  has_one :payment_subscription, dependent: :destroy
  has_one :receipt, dependent: :destroy

  has_one :muser, through: :payment_membership, source: :user
  has_one :suser, through: :payment_subscription, source: :user

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  enum :method, { cash: 0, pos: 1, bank_transfer: 2, voucher: 3 }, default: :cash

  scope :by_created_at, ->(from, to) { where(created_at: from..to).order(created_at: :desc) }

  def self.filter(params)
    case params[:visibility]
    when 'all'
      all
    when 'deleted'
      discarded
    else
      kept
    end
  end

  def self.daily_cash(period)
    return if period.blank?

    mid = Time.zone.now.beginning_of_day
    select_range = ->(y) { kept.by_created_at(mid + y.first, mid + y.last) }

    select_range.call(period == :morning ? [7.hours, 14.hours] : [14.hours, 21.hours])
  end

  def self.humanize_payment_methods
    methods.keys.map { |key| [Payment.human_attribute_name("method.#{key}"), key] }
  end

  def humanize_payment_method(method = self.method)
    Payment.human_attribute_name("method.#{method}")
  end

  def humanize_payable_type
    mem = payment_membership
    sub = payment_subscription

    return unless mem.present? || sub.present?

    type = mem.present? ? 'membership' : 'subscription'

    Payment.human_attribute_name("payable.#{type}")
  end

  def amount_to_currency
    ActionController::Base.helpers.number_to_currency amount
  end
end
