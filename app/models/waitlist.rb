# frozen_string_literal: true

# Waitlist Model
class Waitlist < ApplicationRecord
  # Associations
  belongs_to :member
  belongs_to :product

  # Enums
  enum :priority, {
    normal: 0,
    high: 1,
    urgent: 2
  }, prefix: true

  # Validations
  validates :member_id, uniqueness: {
    scope: :product_id,
    message: "is already on the waitlist for this product"
  }

  # Scopes
  scope :by_priority, -> { order(:priority, :created_at) }
  scope :by_product, ->(product) { where(product: product) }
  scope :by_member, ->(member) { where(member: member) }
  scope :for_product_type, ->(type) { joins(:product).where(products: { product_type: type }) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def position_in_queue
    self.class.where(product: product)
             .where("(priority > ?) OR (priority = ? AND created_at < ?)",
                    priority_before_type_cast, priority_before_type_cast, created_at)
             .count + 1
  end

  def member_name
    "#{member.name} #{member.surname}"
  end

  def product_name
    product.name
  end

  def waiting_since
    created_at.strftime("%d/%m/%Y")
  end

  def days_waiting
    (Date.current - created_at.to_date).to_i
  end

  def can_be_registered?
    # Check if product has available capacity
    return true unless product.capacity

    current_registrations = product.registrations.kept
                                  .joins(:member)
                                  .where("start_date <= ? AND end_date >= ?", Date.current, Date.current)
                                  .where(status: :active)
                                  .count

    current_registrations < product.capacity
  end

  def notify_if_available!
    return false unless can_be_registered?

    # Here you would implement notification logic
    # For now, we'll just return true to indicate notification should be sent
    true
  end

  def self.notify_available_spots
    # Find all waitlist entries where product has available capacity
    includes(:product, :member).each do |waitlist_entry|
      next unless waitlist_entry.can_be_registered?

      # Implement notification logic here
      # Could be email, SMS, in-app notification, etc.
      waitlist_entry.notify_if_available!
    end
  end

  def self.process_queue_for_product(product)
    # Get waitlist entries for this product in priority order
    waitlist_entries = where(product: product).by_priority

    available_spots = if product.capacity
      current_count = product.registrations.kept
                            .where("start_date <= ? AND end_date >= ?", Date.current, Date.current)
                            .where(status: :active)
                            .count
      [ product.capacity - current_count, 0 ].max
    else
      Float::INFINITY # Unlimited capacity
    end

    return [] if available_spots == 0

    # Return the members who can be offered registration
    waitlist_entries.limit(available_spots == Float::INFINITY ? nil : available_spots)
  end

  def self.cleanup_expired_waitlists
    # Remove waitlist entries for products that are no longer active
    joins(:product).where(products: { active: false }).destroy_all

    # Optionally remove very old waitlist entries (e.g., older than 6 months)
    where("created_at < ?", 6.months.ago).destroy_all
  end
end
