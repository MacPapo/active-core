module MembershipBusiness
  extend ActiveSupport::Concern

  included do
    scope :with_active_membership, -> {
      joins(:memberships).where(memberships: { status: :active })
    }
  end

  def has_active_membership?
    current_membership.present?
  end

  def current_membership
    memberships.active.order(created_at: :desc).first
  end

  def can_register_for_product?(product)
    product.requires_membership? ? has_active_membership? : true
  end

  def membership_status
    return :none unless has_active_membership?
    current_membership.expires_soon? ? :expiring : :active
  end
end
