module PolymorphicAssociationManagement
  extend ActiveSupport::Concern

  included do
    scope :memberships, -> { where(payable_type: "Membership") }
    scope :registrations, -> { where(payable_type: "Registration") }
    scope :packages, -> { where(payable_type: "PackagePurchase") }
    scope :for_member, ->(member) {
      where(
        "(payable_type = 'Membership' AND payable_id IN (?)) OR " \
        "(payable_type = 'Registration' AND payable_id IN (?)) OR " \
        "(payable_type = 'PackagePurchase' AND payable_id IN (?))",
        member.memberships.pluck(:id),
        member.registrations.pluck(:id),
        member.package_purchases.pluck(:id)
      )
    }
  end

  def payable_member
    case payable_type
    when "Membership" then payable&.member
    when "Registration" then payable&.member
    when "PackagePurchase" then payable&.member
    end
  end

  def payable_service_period
    return nil unless payable.respond_to?(:start_date) && payable.respond_to?(:end_date)
    "#{payable.start_date.strftime('%b %d')} - #{payable.end_date.strftime('%b %d, %Y')}"
  end

  def payable_status
    payable.respond_to?(:status) ? payable.status : :unknown
  end

  def payable_active?
    payable.respond_to?(:active?) ? payable.active? : false
  end

  def links_to_active_service?
    payable_active? && payable_status == "active"
  end
end
