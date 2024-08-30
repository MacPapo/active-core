# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  validates :payment_method, :entry_type, :payable, :staff, presence: true

  after_save :activate_membership_or_subscription

  belongs_to :payable, polymorphic: true
  belongs_to :staff

  has_one :receipt, dependent: :destroy

  enum :payment_method, { pos: 0, cash: 1, bank_transfer: 2 }, default: :cash
  enum :entry_type, { income: 0, expense: 1 }, default: :income

  scope :by_type, ->(type) { where(payable_type: type.capitalize) if type.present? }
  scope :by_method, ->(method) { where(payment_method: method) if method.present? }
  scope :order_by_date, ->(date) { order("date #{date&.upcase}") if date.present? }
  scope :order_by_updated_at, ->(direction) { order("updated_at #{direction&.upcase}") if direction.present? }

  scope :by_time_interval, ->(from, to) { where(created_at: from..to).order(created_at: :desc) }

  def self.filter(date, type, method, direction)
    by_type(type).by_method(method).order_by_date(date).order_by_updated_at(direction)
  end

  # TODO watch this
  def self.daily_cash(arg)
    return nil if arg.blank?

    mid = Time.zone.now.beginning_of_day
    select_range = ->(y) { by_time_interval(mid + y.first, mid + y.last) }

    select_range.call(
      arg == :morning ? [8.hours, 12.hours] : [15.hours, 20.hours]
    )
  end

  def payment_summary
    payable.summary
  end

  def user
    payable&.user
  end

  def humanize_payable_type(type = payable_type)
    Payment.human_attribute_name("payable.#{type.downcase}")
  end

  def humanize_payment_method(method = payment_method)
    Payment.human_attribute_name("method.#{method}")
  end

  def humanize_entry_type(type = entry_type)
    Payment.human_attribute_name("type.#{type}")
  end

  def self.humanize_payment_methods
    payment_methods.keys.map do |key|
      [Payment.human_attribute_name("method.#{key}"), key]
    end
  end

  def self.humanize_entry_types
    entry_types.keys.map do |key|
      [Payment.human_attribute_name("type.#{key}"), key]
    end
  end

  private

  def set_default_date
    self.date ||= Time.zone.today
  end

  # TODO undo activation if payment is destroyed
  def activate_membership_or_subscription
    ActivateThingJob.perform_later(payable_type, payable_id)
  end
end
