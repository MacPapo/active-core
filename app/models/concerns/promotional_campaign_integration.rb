# TODO
module PromotionalCampaignIntegration
  extend ActiveSupport::Concern

  def campaign_active?
    active? && currently_valid?
  end

  def campaign_urgency
    return :expired if expired?
    return :expires_today if valid_until == Date.current
    return :expires_soon if expires_soon?(3)
    return :limited_time if valid_until.present?
    :ongoing
  end

  def promotional_message
    urgency = campaign_urgency
    base_message = "#{discount_description} on #{applies_to_service_type.downcase}"

    case urgency
    when :expires_today then "⚡ LAST DAY: #{base_message}"
    when :expires_soon then "⏰ #{base_message} - Expires #{valid_until.strftime('%b %d')}"
    when :limited_time then "🎯 #{base_message} - Until #{valid_until.strftime('%b %d')}"
    else base_message
    end
  end

  def estimated_savings_for(member)
    # Calculate potential savings based on member's typical purchases
    return 0 unless applicable_to_member?(member)

    case applicable_to
    when "memberships"
      avg_membership_cost = member.memberships.average(:amount_paid) || 50
      calculate_discount_for(avg_membership_cost)
    when "courses"
      avg_course_cost = member.registrations.average(:amount_paid) || 30
      calculate_discount_for(avg_course_cost)
    when "packages"
      avg_package_cost = member.package_purchases.average(:amount_paid) || 100
      calculate_discount_for(avg_package_cost)
    else
      calculate_discount_for(50) # Assume average service cost
    end
  end
end
