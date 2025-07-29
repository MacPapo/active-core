# frozen_string_literal: true

class PackageInclusion < ApplicationRecord
  # Enums
  enum :access_type, {
         single_use: 0,
         limited: 1,
         unlimited: 2
       }, prefix: true

  # Associations
  belongs_to :package
  belongs_to :product

  # Validations
  validates :access_type, presence: true
  validates :session_limit,
            presence: { if: :access_type_limited? },
            numericality: { greater_than: 0, only_integer: true, if: :session_limit_required? },
            absence: { unless: :session_limit_required? }
  validates :notes, length: { maximum: 500 }, allow_blank: true

  # Custom validations
  validate :unique_product_per_package
  validate :session_limit_reasonable
  validate :product_appropriate_for_package

  # Scopes
  scope :unlimited_access, -> { where(access_type: :unlimited) }
  scope :limited_access, -> { where(access_type: :limited) }
  scope :single_use_access, -> { where(access_type: :single_use) }
  scope :by_product_type, ->(type) { joins(:product).where(products: { product_type: type }) }
  scope :requiring_membership, -> { joins(:product).where(products: { requires_membership: true }) }

  # Instance methods
  def display_access_description
    case access_type.to_sym
    when :single_use
      "Single use access"
    when :limited
      "#{session_limit} session#{session_limit == 1 ? '' : 's'}"
    when :unlimited
      "Unlimited access"
    else
      access_type.humanize
    end
  end

  def full_description
    description = "#{product.name} - #{display_access_description}"
    description += " (#{notes})" if notes.present?
    description
  end

  def estimated_value_for_member(member)
    cheapest_plan = product.cheapest_price(affiliated: member.affiliated?)
    return 0 unless cheapest_plan

    case access_type.to_sym
    when :single_use
      cheapest_plan
    when :limited
      cheapest_plan * session_limit
    when :unlimited
      cheapest_plan * 3 # Assume unlimited = 3x value for estimation
    else
      cheapest_plan
    end
  end

  def can_be_used_by?(member)
    # Check if member meets product requirements
    return false if product.requires_membership? && !member.has_active_membership?
    return false unless product.active?

    true
  end

  private

  def session_limit_required?
    access_type_limited?
  end

  def unique_product_per_package
    return unless package_id.present? && product_id.present?

    existing = PackageInclusion.where(package: package, product: product)
    existing = existing.where.not(id: id) unless new_record?

    if existing.exists?
      errors.add(:product, "is already included in this package")
    end
  end

  def session_limit_reasonable
    return unless session_limit.present?

    if session_limit > 100
      errors.add(:session_limit, "cannot exceed 100 sessions")
    end
  end

  def product_appropriate_for_package
    return unless product.present?

    # Memberships cannot be included in packages (business rule)
    if product.membership?
      errors.add(:product, "memberships cannot be included in packages")
    end

    # Unlimited access not appropriate for certain product types
    if access_type_unlimited? && product.equipment_rental?
      errors.add(:access_type, "unlimited access not available for equipment rentals")
    end
  end
end
