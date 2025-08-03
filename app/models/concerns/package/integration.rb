module Package::Integration
  extend ActiveSupport::Concern

  included do
    scope :from_package, -> { where.not(package_id: nil) }
    scope :standalone, -> { where(package_id: nil) }
    scope :by_package, ->(package) { where(package: package) if package }
  end

  def from_package?
    package_id.present?
  end

  def standalone_registration?
    !from_package?
  end

  # TODO localize
  def package_benefits
    return [] unless from_package?

    @inclusion ||= package.package_inclusions.find_by(product: product)
    return [] unless @inclusion

    benefits = [ I18n.t("packages.benefits.part_of_package", name: package.name) ]

    if @inclusion.session_limit
      benefits << I18n.t("packages.benefits.sessions_included", count: @inclusion.session_limit)
    elsif @inclusion.access_type == "unlimited"
      benefits << I18n.t("packages.benefits.unlimited_access")
    end

    benefits
  end

  def sync_with_package_purchase!
    return unless from_package?

    package_purchase = member.package_purchases.find_by(package: package, status: :active)
    return unless package_purchase

    update!(
      start_date: [ start_date, package_purchase.start_date ].max,
      end_date: [ end_date, package_purchase.end_date ].min
    )
  end
end
