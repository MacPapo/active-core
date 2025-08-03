module Product::MembershipRequirement
  extend ActiveSupport::Concern

  included do
    scope :membership_required, -> { where(requires_membership: true) }
    scope :open_access, -> { where(requires_membership: false) }
  end

  def requires_membership?
    requires_membership
  end

  def open_access?
    !requires_membership?
  end

  def can_be_accessed_by?(member)
    return true unless requires_membership?
    return false unless member

    member.active_membership?
  end

  # TODO localization
  def access_requirements
    requirements = []
    requirements << "Active membership" if requires_membership?
    # requirements << "Valid medical certificate" TODO
    requirements
  end
end
