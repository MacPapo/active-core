# frozen_string_literal: true

# PricingPlan Model
class PricingPlan < ApplicationRecord
  include Discard::Model

  # Enums
  enum :duration_type, {
         session: 0,
         daily: 1,
         weekly: 2,
         monthly: 3,
         quarterly: 4,
         semi_annual: 5,
         yearly: 6,
         lifetime: 7
       }, prefix: true

  # Associations
  belongs_to :product
  has_many :memberships, dependent: :restrict_with_error
  has_many :registrations, dependent: :restrict_with_error

  # Through associations
  has_many :members, through: :memberships
  has_many :registered_members, through: :registrations, source: :member

  # Validations
  validates :duration_type, presence: true
  validates :duration_value,
            presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :price,
            presence: true,
            numericality: { greater_than: 0 }
  validates :affiliated_price,
            numericality: { greater_than: 0 },
            allow_nil: true

  # Custom validations
  validate :affiliated_price_lower_than_regular_price
  validate :duration_value_appropriate_for_type
  validate :valid_date_range
  validate :no_overlapping_plans_for_product
  validate :lifetime_duration_restrictions

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, -> { where("(valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)", Date.current, Date.current) }
  scope :expired, -> { where("valid_until < ?", Date.current) }
  scope :future, -> { where("valid_from > ?", Date.current) }
  scope :by_duration_type, ->(type) { where(duration_type: type) }
  scope :by_product_type, ->(product_type) { joins(:product).where(products: { product_type: product_type }) }
  scope :memberships_only, -> { joins(:product).where(products: { product_type: "membership" }) }
  scope :activities_only, -> { joins(:product).where(products: { product_type: "activity" }) }
  scope :cheapest_first, -> { order(:price) }
  scope :most_expensive_first, -> { order(price: :desc) }
  scope :shortest_first, -> { order(:duration_type, :duration_value) }
  scope :longest_first, -> { order(duration_type: :desc, duration_value: :desc) }

  # Callbacks
  before_save :calculate_affiliated_price_if_blank
  before_save :set_duration_value_for_lifetime
  after_discard :handle_active_subscriptions

  # Instance methods
  def current?
    return true if valid_from.blank? && valid_until.blank?
    return false if valid_from.present? && valid_from > Date.current
    return false if valid_until.present? && valid_until < Date.current
    true
  end

  def expired?
    valid_until.present? && valid_until < Date.current
  end

  def future?
    valid_from.present? && valid_from > Date.current
  end

  def price_for_member(member)
    if member.affiliated? && affiliated_price.present?
      affiliated_price
    else
      price
    end
  end

  def discount_amount_for_member(member)
    return 0 unless member.affiliated? && affiliated_price.present?
    price - affiliated_price
  end

  def discount_percentage_for_member(member)
    return 0 unless member.affiliated? && affiliated_price.present?
    ((price - affiliated_price) / price * 100).round(2)
  end

  def duration_in_days
    case duration_type.to_sym
    when :session
      1 # Single session
    when :daily
      duration_value
    when :weekly
      duration_value * 7
    when :monthly
      duration_value * 30
    when :quarterly
      duration_value * 90
    when :semi_annual
      duration_value * 180
    when :yearly
      duration_value * 365
    when :lifetime
      999_999 # Effectively unlimited
    else
      duration_value
    end
  end

  def end_date_from_start(start_date)
    return start_date if duration_type_session?
    return Date.new(9999, 12, 31) if duration_type_lifetime?

    start_date + duration_in_days.days - 1.day
  end

  def display_duration
    case duration_type.to_sym
    when :session
      duration_value == 1 ? "1 Session" : "#{duration_value} Sessions"
    when :daily
      duration_value == 1 ? "1 Day" : "#{duration_value} Days"
    when :weekly
      duration_value == 1 ? "1 Week" : "#{duration_value} Weeks"
    when :monthly
      duration_value == 1 ? "1 Month" : "#{duration_value} Months"
    when :quarterly
      duration_value == 1 ? "1 Quarter" : "#{duration_value} Quarters"
    when :semi_annual
      duration_value == 1 ? "6 Months" : "#{duration_value * 6} Months"
    when :yearly
      duration_value == 1 ? "1 Year" : "#{duration_value} Years"
    when :lifetime
      "Lifetime"
    else
      "#{duration_value} #{duration_type.humanize}"
    end
  end

  def monthly_equivalent_price(member = nil)
    actual_price = member ? price_for_member(member) : price
    monthly_days = 30.0

    case duration_type.to_sym
    when :session, :daily
      actual_price * (monthly_days / duration_in_days)
    when :weekly
      actual_price * (monthly_days / 7.0) / duration_value
    when :monthly
      actual_price / duration_value
    when :quarterly
      actual_price / (duration_value * 3.0)
    when :semi_annual
      actual_price / (duration_value * 6.0)
    when :yearly
      actual_price / (duration_value * 12.0)
    when :lifetime
      0 # Lifetime plans have no monthly equivalent
    else
      actual_price / (duration_in_days / monthly_days)
    end
  end

  def cost_per_day(member = nil)
    actual_price = member ? price_for_member(member) : price
    return actual_price if duration_type_session?
    return 0 if duration_type_lifetime?

    actual_price / duration_in_days
  end

  def can_be_purchased_by?(member)
    return false unless active? && current?
    return false unless product.active?

    # Check if member meets product requirements
    return false if product.requires_membership? && !member.has_active_membership?

    true
  end

  def usage_count
    memberships.count + registrations.count
  end

  def revenue_generated(start_date = nil, end_date = nil)
    scope = memberships.joins(:payment_items)
              .joins("JOIN payments ON payment_items.payment_id = payments.id")
              .where(payments: { income: true })

    scope = scope.where(payments: { date: start_date..end_date }) if start_date && end_date
    scope.sum("payment_items.amount")
  end

  # Class methods
  def self.best_value_for_product(product, member = nil)
    plans = product.active_pricing_plans.current
    return nil if plans.empty?

    plans.min_by { |plan| plan.monthly_equivalent_price(member) }
  end

  def self.cheapest_for_product(product, member = nil)
    plans = product.active_pricing_plans.current
    return nil if plans.empty?

    if member&.affiliated?
      plans.min_by { |plan| plan.price_for_member(member) }
    else
      plans.min_by(&:price)
    end
  end

  private

  def affiliated_price_lower_than_regular_price
    return unless affiliated_price.present?
    return unless price.present?
    return if affiliated_price < price

    errors.add(:affiliated_price, "must be lower than regular price")
  end

  def duration_value_appropriate_for_type
    return unless duration_value.present?

    case duration_type&.to_sym
    when :lifetime
      errors.add(:duration_value, "should be 1 for lifetime plans") unless duration_value == 1
    when :session
      errors.add(:duration_value, "cannot exceed 50 for session plans") if duration_value > 50
    when :daily
      errors.add(:duration_value, "cannot exceed 365 for daily plans") if duration_value > 365
    when :weekly
      errors.add(:duration_value, "cannot exceed 52 for weekly plans") if duration_value > 52
    when :monthly
      errors.add(:duration_value, "cannot exceed 24 for monthly plans") if duration_value > 24
    when :quarterly
      errors.add(:duration_value, "cannot exceed 8 for quarterly plans") if duration_value > 8
    when :semi_annual
      errors.add(:duration_value, "cannot exceed 4 for semi-annual plans") if duration_value > 4
    when :yearly
      errors.add(:duration_value, "cannot exceed 5 for yearly plans") if duration_value > 5
    end
  end

  def valid_date_range
    return unless valid_from.present? && valid_until.present?
    return if valid_from <= valid_until

    errors.add(:valid_until, "must be after valid_from date")
  end

  def no_overlapping_plans_for_product
    return unless product_id.present?
    return unless duration_type.present? && duration_value.present?

    overlapping = PricingPlan.where(product: product, duration_type: duration_type, duration_value: duration_value)
                    .where.not(id: id)
                    .active

    # Check for date range overlaps
    if valid_from.present? || valid_until.present?
      overlapping = overlapping.where(
        '(valid_from IS NULL AND valid_until IS NULL) OR
         (valid_from IS NULL AND valid_until >= ?) OR
         (valid_until IS NULL AND valid_from <= ?) OR
         (valid_from <= ? AND valid_until >= ?)',
        valid_from || Date.new(1900, 1, 1),
        valid_until || Date.new(2100, 12, 31),
        valid_until || Date.new(2100, 12, 31),
        valid_from || Date.new(1900, 1, 1)
      )
    end

    if overlapping.exists?
      errors.add(:base, "A pricing plan with the same duration already exists for this product in the specified date range")
    end
  end

  def lifetime_duration_restrictions
    return unless duration_type_lifetime?
    return unless product&.activity?

    errors.add(:duration_type, "lifetime plans are not allowed for activities")
  end

  def calculate_affiliated_price_if_blank
    return if affiliated_price.present?
    return unless price.present?

    # Auto-calculate 20% discount for affiliated members if not specified
    self.affiliated_price = (price * 0.8).round(2)
  end

  def set_duration_value_for_lifetime
    self.duration_value = 1 if duration_type_lifetime?
  end

  def handle_active_subscriptions
    # When a pricing plan is discarded, we need to handle active memberships/registrations
    # Log warning but don't prevent the discard - business decision
    if memberships.exists? || registrations.exists?
      Rails.logger.warn "PricingPlan #{id} discarded with active subscriptions"
    end
  end
end
