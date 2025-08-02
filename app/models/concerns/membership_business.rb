module MembershipBusiness
  extend ActiveSupport::Concern

  included do
    scope :with_active_membership, -> {
      kept.joins(:memberships).where(memberships: { status: :active }).distinct
    }
  end

  def current_membership
    @current_membership ||= memberships.kept.order(created_at: :desc).first
  end

  def has_active_membership?
    current_membership.present? && current_membership.active?
  end

  def can_register_for_product?(product)
    product.requires_membership? ? has_active_membership? : true
  end

  def membership_status
    membership = current_membership

    return :none unless membership.present? && membership.active?

    membership.expires_soon? ? :expiring : :active
  end
end
