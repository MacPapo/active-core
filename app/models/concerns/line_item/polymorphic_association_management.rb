module LineItem::PolymorphicAssociationManagement
  extend ActiveSupport::Concern

  included do
    scope :memberships, -> { where(payable_type: "Membership") }
    scope :registrations, -> { where(payable_type: "Registration") }
    scope :packages, -> { where(payable_type: "PackagePurchase") }

    scope :for_member, ->(member) {
      # OLD
      # where(
      #   "(payable_type = 'Membership' AND payable_id IN (?)) OR " \
      #   "(payable_type = 'Registration' AND payable_id IN (?)) OR " \
      #   "(payable_type = 'PackagePurchase' AND payable_id IN (?))",
      #   member.memberships.pluck(:id),
      #   member.registrations.pluck(:id),
      #   member.package_purchases.pluck(:id)
      # )

      member_related_ids = member.memberships.pluck(:id).map { |id| [ "Membership", id ] } +
                           member.registrations.pluck(:id).map { |id| [ "Registration", id ] } +
                           member.package_purchases.pluck(:id).map { |id| [ "PackagePurchase", id ] }

      where(member_related_ids.map { |type, id| "(payable_type = '#{type}' AND payable_id = #{id})" }.join(" OR "))
    }
  end

  def payable_member
    payable&.member
  end

  # TODO localization
  def payable_service_period
    return nil unless payable.respond_to?(:start_date) && payable.respond_to?(:end_date)

    I18n.t("line_items.service_period",
      start_date: I18n.l(payable.start_date, format: :short),
      end_date: I18n.l(payable.end_date, format: :long)
    )
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
