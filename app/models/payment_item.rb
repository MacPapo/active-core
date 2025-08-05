# frozen_string_literal: true

# PaymentItem Model
class PaymentItem < ApplicationRecord
  include Discard::Model
  include Financial::ItemAnalytics, Financial::RevenueAttribution
  include LineItem::Management, LineItem::PolymorphicAssociationManagement

  # Associations
  belongs_to :payment
  belongs_to :payable, polymorphic: true

  # Delegations for clean API
  delegate :user, :date, :payment_method, to: :payment, allow_nil: true
  delegate :full_name, to: :payable_member, prefix: :member, allow_nil: true

  # Callbacks
  after_save :update_payment_totals
  after_destroy :update_payment_totals
  before_validation :set_default_amount

  def display_summary
    member_name = member_full_name || "Unknown"
    service_info = display_description
    "#{member_name} - #{service_info} (€#{amount})"
  end

  def self.revenue_by_service_type
    revenue_generating
      .group(:payable_type)
      .sum(:amount)
      .transform_keys { |k| k.underscore.humanize }
  end

  private

  def update_payment_totals
    payment&.send(:ensure_amounts_consistency)
    payment&.save! if payment&.changed?
  end

  def set_default_amount
    self.amount ||= payable&.price || 0.0
  end
end
