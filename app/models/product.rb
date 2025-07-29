# frozen_string_literal: true

# Product Model
class Product < ApplicationRecord
  include Discard::Model

  # Constants for product types
  PRODUCT_TYPES = %w[membership activity service equipment_rental].freeze

  # Associations
  has_many :pricing_plans, dependent: :destroy
  has_many :active_pricing_plans, -> { where(active: true) }, class_name: "PricingPlan"
  has_many :registrations, dependent: :restrict_with_error
  has_many :package_inclusions, dependent: :destroy
  has_many :packages, through: :package_inclusions
  has_many :waitlists, dependent: :destroy

  # Through associations for easier querying
  has_many :members, through: :registrations
  has_many :active_registrations, -> { where(status: :active) }, class_name: "Registration"
  has_many :active_members, through: :active_registrations, source: :member

  # Validations
  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :product_type, case_sensitive: false, conditions: -> { where(discarded_at: nil) } }
  validates :product_type,
            presence: true,
            inclusion: { in: PRODUCT_TYPES }
  validates :description,
            length: { maximum: 1000 },
            allow_blank: true
  validates :capacity,
            numericality: { greater_than: 0, only_integer: true },
            allow_nil: true

  # Custom validations
  validate :membership_type_cannot_require_membership
  validate :capacity_required_for_activities

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_type, ->(type) { where(product_type: type) }
  scope :memberships, -> { where(product_type: "membership") }
  scope :activities, -> { where(product_type: "activity") }
  scope :services, -> { where(product_type: "service") }
  scope :equipment_rentals, -> { where(product_type: "equipment_rental") }
  scope :requiring_membership, -> { where(requires_membership: true) }
  scope :not_requiring_membership, -> { where(requires_membership: false) }
  scope :with_capacity, -> { where.not(capacity: nil) }
  scope :available_capacity, -> { joins(:active_registrations).group("products.id").having("COUNT(registrations.id) < products.capacity") }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") }

  # Callbacks
  before_save :normalize_name
  after_discard :handle_discard_cascade

  # Instance methods
  def membership?
    product_type == "membership"
  end

  def activity?
    product_type == "activity"
  end

  def service?
    product_type == "service"
  end

  def equipment_rental?
    product_type == "equipment_rental"
  end

  def has_capacity_limit?
    capacity.present?
  end

  def current_registrations_count
    @current_registrations_count ||= active_registrations.count
  end

  def available_spots
    return nil unless has_capacity_limit?
    capacity - current_registrations_count
  end

  def full?
    return false unless has_capacity_limit?
    available_spots <= 0
  end

  def nearly_full?(threshold = 0.8)
    return false unless has_capacity_limit?
    (current_registrations_count.to_f / capacity) >= threshold
  end

  def can_accept_registration?
    active? && !full?
  end

  def has_active_pricing_plans?
    active_pricing_plans.exists?
  end

  def default_pricing_plan
    active_pricing_plans.order(:price).first
  end

  def pricing_plan_for_duration(duration_type, duration_value = nil)
    plans = active_pricing_plans.where(duration_type: duration_type)
    plans = plans.where(duration_value: duration_value) if duration_value
    plans.order(:price).first
  end

  def cheapest_price(affiliated: false)
    return nil unless has_active_pricing_plans?

    if affiliated
      active_pricing_plans.minimum(:affiliated_price) || active_pricing_plans.minimum(:price)
    else
      active_pricing_plans.minimum(:price)
    end
  end

  def most_expensive_price(affiliated: false)
    return nil unless has_active_pricing_plans?

    if affiliated
      active_pricing_plans.where.not(affiliated_price: nil).maximum(:affiliated_price) ||
        active_pricing_plans.maximum(:price)
    else
      active_pricing_plans.maximum(:price)
    end
  end

  def waitlist_position_for_member(member)
    waitlist = waitlists.find_by(member: member)
    return nil unless waitlist

    waitlists.where("priority < ? OR (priority = ? AND created_at < ?)",
                    waitlist.priority, waitlist.priority, waitlist.created_at).count + 1
  end

  def add_to_waitlist(member, priority: 0)
    return false if active_registrations.exists?(member: member)

    waitlists.find_or_create_by(member: member) do |waitlist|
      waitlist.priority = priority
    end
  end

  def remove_from_waitlist(member)
    waitlists.find_by(member: member)&.destroy
  end

  def next_waitlist_member
    waitlists.joins(:member)
      .where(members: { discarded_at: nil })
      .order(:priority, :created_at)
      .first&.member
  end

  # Class methods
  def self.available_for_registration
    active.joins(:active_pricing_plans)
      .where('products.capacity IS NULL OR products.capacity > (
             SELECT COUNT(*) FROM registrations
             WHERE registrations.product_id = products.id
             AND registrations.status = 0
           )')
  end

  def self.popular(limit = 5)
    joins(:registrations)
      .group("products.id")
      .order("COUNT(registrations.id) DESC")
      .limit(limit)
  end

  def self.revenue_by_product(start_date = 1.month.ago, end_date = Date.current)
    joins(registrations: :payment_items)
      .joins("JOIN payments ON payment_items.payment_id = payments.id")
      .where(payments: { date: start_date..end_date, income: true })
      .group("products.id, products.name")
      .sum("payment_items.amount")
  end

  private

  def membership_type_cannot_require_membership
    return unless membership? && requires_membership?
    errors.add(:requires_membership, "cannot be true for membership products")
  end

  def capacity_required_for_activities
    return unless activity? && capacity.blank?
    errors.add(:capacity, "is required for activity products")
  end

  def normalize_name
    self.name = name&.strip&.titleize
  end

  def handle_discard_cascade
    # Discard related pricing plans when product is discarded
    pricing_plans.discard_all
    # Destroy waitlists (they're simple join records)
    waitlists.destroy_all
    # Package inclusions should be destroyed to maintain package integrity
    package_inclusions.destroy_all
  end
end
