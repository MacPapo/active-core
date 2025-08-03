module Discount::Applicability
  extend ActiveSupport::Concern

  def applicable_to?(item)
    return false unless active? && currently_valid?

    case applicable_to
    when "all_services" then true
    when "memberships" then item.is_a?(Membership)
    when "courses" then item.is_a?(Registration)
    when "packages" then item.is_a?(PackagePurchase)
    else false
    end
  end

  def can_apply_to_member?(member)
    true # Override in subclasses for member-specific rules
  end

  # TODO localize
  def applies_to_service_type
    case applicable_to
    when "all_services" then "All services"
    when "memberships" then "Gym memberships only"
    when "courses" then "Course registrations only"
    when "packages" then "Package purchases only"
    else "Unknown"
    end
  end

  def compatible_with?(other_discount)
    return false if self == other_discount
    return false unless stackable? && other_discount.stackable?
    return false if applicable_to == other_discount.applicable_to && discount_type == other_discount.discount_type

    true
  end
end
