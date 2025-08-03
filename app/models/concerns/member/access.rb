module Member::Access
  extend ActiveSupport::Concern

  def member_eligible?
    return false unless member.present?

    # TODO next release
    # eligible = member.medical_certificate_valid?
    # eligible &&= member.legal_guardian.present? if member.minor?

    eligible
  end

  def grants_gym_access?
    current? && member_eligible?
  end

  def access_level
    return :none unless grants_gym_access?

    member.affiliated? ? :premium : :standard
  end

  def can_register_for?(product)
    grants_gym_access? && product.can_be_accessed_by?(member)
  end
end
