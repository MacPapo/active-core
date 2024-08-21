# frozen_string_literal: true

# Payment Model
class Payment < ApplicationRecord
  after_initialize :set_default_date, if: :new_record?

  after_save :activate_membership_or_subscription

  belongs_to :payable, polymorphic: true
  belongs_to :staff

  enum :payment_method, %i[pos cash bank_transfer], default: :cash
  enum :entry_type, %i[income expense], default: :income

  validates :payment_method, :entry_type, :payable, :staff, presence: true

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
    case payable_type
    when 'Membership'
      membership = Membership.find(payable_id)
      membership.active!
    when 'Subscription'
      subscription = Subscription.find(payable_id)
      subscription.active!

      subscription.open_subscription&.active! if subscription.open?
    end
  end
end
