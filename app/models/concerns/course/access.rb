module Course::Access
  extend ActiveSupport::Concern

  included do
    scope :for_product, ->(product) { where(product: product) }
    scope :requiring_membership, -> { joins(:product).where(products: { requires_membership: true }) }
    scope :open_access, -> { joins(:product).where(products: { requires_membership: false }) }
  end

  def can_attend?
    active? &&
    !expired? &&
    member&.medical_certificate_valid? &&
    !sessions_exhausted? &&
      (!product&.requires_membership? || member&.active_membership?)
  end

  # TODO localization
  def attendance_requirements
    requirements = []
    requirements << I18n.t("requirements.active_registration") unless active?
    requirements << I18n.t("requirements.valid_medical_certificate") unless member&.medical_certificate_valid?
    requirements << I18n.t("requirements.sessions_remaining") if sessions_exhausted?
    if product&.requires_membership? && !member&.active_membership?
      requirements << I18n.t("requirements.active_membership")
    end
    requirements
  end

  def access_level
    return :none unless can_attend?
    member.affiliated? ? :premium : :standard
  end
end
