# frozen_string_literal: true

# Discount Model
class Discount < ApplicationRecord
  include Discard::Model

  include ValidityPeriod
  include Discount::Mechanics, Discount::Applicability, Discount::UsageTracking, Discount::PromotionalCampaignIntegration

  # Associations
  has_many :payment_discounts, dependent: :destroy
  has_many :payments, through: :payment_discounts

  # Active scope combining multiple concerns
  scope :active, -> { where(active: true).currently_valid }
  scope :promotional, -> { active.where.not(valid_until: nil) }

  # Callbacks
  before_save :validate_discount_logic
  after_update :notify_if_deactivated

  def self.applicable_for(item, member = nil)
    active.select { |discount| discount.applicable_to?(item) && discount.can_apply_to_member?(member) }
  end

  def self.best_discount_for(amount, item, member = nil)
    applicable_for(item, member)
      .max_by { |discount| discount.calculate_discount_for(amount) }
  end

  def display_name
    "#{name} (#{discount_description})"
  end

  private

  def validate_discount_logic
    if percentage_discount? && value > 100
      errors.add(:value, "percentage cannot exceed 100%")
    end

    if fixed_amount_discount? && max_amount.present?
      errors.add(:max_amount, "not applicable to fixed amount discounts")
    end
  end

  def notify_if_deactivated
    nil unless saved_change_to_active? && !active?
    # Could trigger notification job here
  end
end
