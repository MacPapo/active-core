module MemberIntegration
  extend ActiveSupport::Concern

  def member_eligible?
    member.medical_certificate_valid? &&
    (member.minor? ? member.legal_guardian.present? : true)
  end

  def grants_gym_access?
    current? && member_eligible?
  end

  def access_level
    return :none unless grants_gym_access?
    member.affiliated? ? :premium : :standard
  end

  def can_register_for?(product)
    grants_gym_access? && product.accessible_by?(member)
  end
end
