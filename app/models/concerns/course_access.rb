module CourseAccess
  extend ActiveSupport::Concern

  included do
    scope :for_product, ->(product) { where(product: product) }
    scope :requiring_membership, -> { joins(:product).where(products: { requires_membership: true }) }
    scope :open_access, -> { joins(:product).where(products: { requires_membership: false }) }
  end

  def can_attend?
    return false unless active? && !expired?
    return false unless member.medical_certificate_valid?
    return false if sessions_exhausted?
    return false if product.requires_membership? && !member.has_active_membership?

    true
  end

  def attendance_requirements
    requirements = []
    requirements << "Active registration" unless active?
    requirements << "Valid medical certificate" unless member.medical_certificate_valid?
    requirements << "Sessions remaining" if sessions_exhausted?
    requirements << "Active membership" if product.requires_membership? && !member.has_active_membership?
    requirements
  end

  def access_level
    return :none unless can_attend?
    member.affiliated? ? :premium : :standard
  end
end
