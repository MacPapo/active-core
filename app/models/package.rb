# frozen_string_literal: true

class Package < ApplicationRecord
  include Discard::Model

  # Enums
  enum :duration_type, {
         days: 0,
         weeks: 1,
         months: 2,
         quarters: 3,
         years: 4
       }, prefix: true

  # Associations
  has_many :package_inclusions, dependent: :destroy
  has_many :products, through: :package_inclusions
  has_many :package_purchases, dependent: :restrict_with_error
  has_many :registrations, dependent: :restrict_with_error

  # Through associations
  has_many :members, through: :package_purchases
  has_many :active_purchases, -> { where(status: :active) }, class_name: "PackagePurchase"
  has_many :active_members, through: :active_purchases, source: :member

  # Validations
  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { case_sensitive: false, conditions: -> { where(discarded_at: nil) } }
  validates :description,
            length: { maximum: 1000 },
            allow_blank: true
  validates :price,
            presence: true,
            numericality: { greater_than: 0 }
  validates :affiliated_price,
            numericality: { greater_than: 0 },
            allow_nil: true
  validates :duration_type, presence: true
  validates :duration_value,
            presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :max_sales,
            numericality: { greater_than: 0, only_integer: true },
            allow_nil: true

  # Custom validations
  validate :affiliated_price_lower_than_regular_price
  validate :valid_date_range
  validate :duration_value_reasonable_for_type
  validate :must_have_at_least_one_inclusion

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :current, -> { where("(valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)", Date.current, Date.current) }
  scope :expired, -> { where("valid_until < ?", Date.current) }
  scope :future, -> { where("valid_from > ?", Date.current) }
  scope :by_duration_type, ->(type) { where(duration_type: type) }
  scope :available_for_sale, -> { active.current.where("max_sales IS NULL OR (SELECT COUNT(*) FROM package_purchases WHERE package_id = packages.id) < max_sales") }
  scope :cheapest_first, -> { order(:price) }
  scope :most_expensive_first, -> { order(price: :desc) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") }

  # Callbacks
  before_save :normalize_name
  before_save :calculate_affiliated_price_if_blank
  after_discard :handle_discard_cascade

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
    when :days
      duration_value
    when :weeks
      duration_value * 7
    when :months
      duration_value * 30
    when :quarters
      duration_value * 90
    when :years
      duration_value * 365
    else
      duration_value
    end
  end

  def end_date_from_start(start_date)
    start_date + duration_in_days.days - 1.day
  end

  def display_duration
    case duration_type.to_sym
    when :days
      duration_value == 1 ? "1 Day" : "#{duration_value} Days"
    when :weeks
      duration_value == 1 ? "1 Week" : "#{duration_value} Weeks"
    when :months
      duration_value == 1 ? "1 Month" : "#{duration_value} Months"
    when :quarters
      duration_value == 1 ? "1 Quarter" : "#{duration_value} Quarters"
    when :years
      duration_value == 1 ? "1 Year" : "#{duration_value} Years"
    else
      "#{duration_value} #{duration_type.humanize}"
    end
  end

  def sales_count
    package_purchases.count
  end

  def remaining_sales
    return nil unless max_sales.present?
    [ max_sales - sales_count, 0 ].max
  end

  def sold_out?
    return false unless max_sales.present?
    sales_count >= max_sales
  end

  def can_be_purchased?
    active? && current? && !sold_out?
  end

  def can_be_purchased_by?(member)
    return false unless can_be_purchased?

    # Check if member meets requirements for all included products
    package_inclusions.joins(:product).where(products: { requires_membership: true }).exists? &&
      !member.has_active_membership? ? false : true
  end

  def included_products_list
    package_inclusions.includes(:product).map do |inclusion|
      product_info = inclusion.product.name
      case inclusion.access_type.to_sym
      when :unlimited
        "#{product_info} (Unlimited)"
      when :limited
        "#{product_info} (#{inclusion.session_limit} sessions)"
      when :single_use
        "#{product_info} (Single use)"
      else
        product_info
      end
    end
  end

  def total_value_for_member(member)
    package_inclusions.sum do |inclusion|
      cheapest_plan = inclusion.product.cheapest_price(affiliated: member.affiliated?)
      next 0 unless cheapest_plan

      case inclusion.access_type.to_sym
      when :unlimited
        cheapest_plan * 2 # Assume unlimited = 2x single price
      when :limited
        cheapest_plan * (inclusion.session_limit || 1)
      when :single_use
        cheapest_plan
      else
        cheapest_plan
      end
    end
  end

  def savings_for_member(member)
    total_value = total_value_for_member(member)
    package_price = price_for_member(member)
    [ total_value - package_price, 0 ].max
  end

  def savings_percentage_for_member(member)
    total_value = total_value_for_member(member)
    return 0 if total_value.zero?

    savings = savings_for_member(member)
    (savings / total_value * 100).round(2)
  end

  def revenue_generated(start_date = nil, end_date = nil)
    scope = package_purchases.joins(:payment_items)
              .joins("JOIN payments ON payment_items.payment_id = payments.id")
              .where(payments: { income: true })

    scope = scope.where(payments: { date: start_date..end_date }) if start_date && end_date
    scope.sum("payment_items.amount")
  end

  # Class methods
  def self.popular(limit = 5)
    joins(:package_purchases)
      .group("packages.id")
      .order("COUNT(package_purchases.id) DESC")
      .limit(limit)
  end

  def self.best_value_packages(member = nil, limit = 5)
    packages = available_for_sale.includes(:package_inclusions, products: :active_pricing_plans)

    packages.sort_by { |package| -package.savings_percentage_for_member(member || Member.new(affiliated: false)) }
      .first(limit)
  end

  private

  def affiliated_price_lower_than_regular_price
    return unless affiliated_price.present? && price.present?
    return if affiliated_price < price

    errors.add(:affiliated_price, "must be lower than regular price")
  end

  def valid_date_range
    return unless valid_from.present? && valid_until.present?
    return if valid_from <= valid_until

    errors.add(:valid_until, "must be after valid_from date")
  end

  def duration_value_reasonable_for_type
    return unless duration_value.present?

    case duration_type&.to_sym
    when :days
      errors.add(:duration_value, "cannot exceed 365 for daily packages") if duration_value > 365
    when :weeks
      errors.add(:duration_value, "cannot exceed 52 for weekly packages") if duration_value > 52
    when :months
      errors.add(:duration_value, "cannot exceed 24 for monthly packages") if duration_value > 24
    when :quarters
      errors.add(:duration_value, "cannot exceed 8 for quarterly packages") if duration_value > 8
    when :years
      errors.add(:duration_value, "cannot exceed 5 for yearly packages") if duration_value > 5
    end
  end

  def must_have_at_least_one_inclusion
    return if new_record? # Skip for new records as inclusions might be added after creation
    return if package_inclusions.exists?

    errors.add(:base, "Package must include at least one product")
  end

  def normalize_name
    self.name = name&.strip&.titleize
  end

  def calculate_affiliated_price_if_blank
    return if affiliated_price.present?
    return unless price.present?

    # Auto-calculate 20% discount for affiliated members if not specified
    self.affiliated_price = (price * 0.8).round(2)
  end

  def handle_discard_cascade
    # Discard package inclusions when package is discarded
    package_inclusions.destroy_all

    # Log warning for active purchases but don't prevent discard
    if package_purchases.exists?
      Rails.logger.warn "Package #{id} discarded with existing purchases"
    end
  end
end
