module MembershipRequirements
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

  def accessible_by?(member)
    return true if open_access?
    member&.has_active_membership? && member&.medical_certificate_valid?
  end

  def access_requirements
    requirements = []
    requirements << "Active membership" if requires_membership?
    requirements << "Valid medical certificate"
    requirements
  end
end
