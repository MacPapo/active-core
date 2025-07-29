# frozen_string_literal: true

# Discount Model
class Discount < ApplicationRecord
  include Discard::Model

  # Associations
  has_many :payment_discounts, dependent: :destroy
  has_many :payments, through: :payment_discounts

  # Enums
  enum :discount_type, {
    percentage: 0,
    fixed_amount: 1
  }, prefix: true

  enum :applicable_to, {
    all: 0,
    memberships: 1,
    activities: 2,
    packages: 3
  }, prefix: true

  # Validations
  validates :name, presence: true, uniqueness: { conditions: -> { kept } }
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :max_amount, numericality: { greater_than: 0 }, allow_nil: true
  validates :valid_from, presence: true, if: :has_validity_period?
  validates :valid_until, presence: true, if: :has_validity_period?
  validates :valid_until, comparison: { greater_than: :valid_from }, if: :has_validity_period?

  validate :percentage_value_range, if: :discount_type_percentage?
  validate :max_amount_for_percentage_only

  # Scopes
  scope :active, -> { where(active: true) }
  scope :valid_today, -> {
    where("(valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)",
          Date.current, Date.current)
  }
  scope :stackable, -> { where(stackable: true) }
  scope :non_stackable, -> { where(stackable: false) }
  scope :by_type, ->(type) { where(discount_type: type) }
  scope :for_memberships, -> { where(applicable_to: [ :all, :memberships ]) }
  scope :for_activities, -> { where(applicable_to: [ :all, :activities ]) }
  scope :for_packages, -> { where(applicable_to: [ :all, :packages ]) }

  # Instance methods
  def valid_today?
    active? &&
    (valid_from.nil? || valid_from <= Date.current) &&
    (valid_until.nil? || valid_until >= Date.current)
  end

  def expired?
    valid_until.present? && valid_until < Date.current
  end

  def days_until_expiry
    return nil unless valid_until
    return 0 if expired?
    (valid_until - Date.current).to_i
  end

  def calculate_discount(amount)
    return 0 unless valid_today?

    discount_amount = case discount_type
    when "percentage"
      (amount * value / 100).round(2)
    when "fixed_amount"
      [ value, amount ].min
    end

    # Apply max_amount cap for percentage discounts
    if discount_type_percentage? && max_amount.present?
      discount_amount = [ discount_amount, max_amount ].min
    end

    discount_amount
  end

  def applicable_to?(item_type)
    case applicable_to
    when "all"
      true
    when "memberships"
      item_type.to_s == "membership"
    when "activities"
      item_type.to_s == "activity" || item_type.to_s == "registration"
    when "packages"
      item_type.to_s == "package"
    else
      false
    end
  end

  def usage_count
    payment_discounts.count
  end

  def total_discount_given
    payment_discounts.sum(:discount_amount)
  end

  def display_value
    case discount_type
    when "percentage"
      "#{value}%"
    when "fixed_amount"
      "€#{value}"
    end
  end

  private

  def has_validity_period?
    valid_from.present? || valid_until.present?
  end

  def percentage_value_range
    return unless discount_type_percentage?
    return unless value.present?

    if value <= 0 || value > 100
      errors.add(:value, "must be between 0 and 100 for percentage discounts")
    end
  end

  def max_amount_for_percentage_only
    return unless max_amount.present?

    unless discount_type_percentage?
      errors.add(:max_amount, "can only be set for percentage discounts")
    end
  end
end
