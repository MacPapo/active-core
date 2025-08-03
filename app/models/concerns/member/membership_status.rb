module Member::MembershipStatus
  extend ActiveSupport::Concern

  included do
    scope :with_active_membership, -> { joins(:memberships).merge(Membership.kept.active).distinct }
  end

  def current_membership
    @current_membership ||= memberships.kept.order(created_at: :desc).first
  end

  def can_register_for_product?(product)
    return true unless product.requires_membership?
    active_membership?
  end

  def active_membership?
    current_membership.present? && current_membership.active?
  end

  def membership_status
    return :none unless active_membership?

    current_membership.expires_soon? ? :expiring : :active
  end
end
