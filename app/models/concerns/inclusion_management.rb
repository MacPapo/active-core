module InclusionManagement
  extend ActiveSupport::Concern

  included do
    scope :with_unlimited_access, -> {
      joins(:package_inclusions).where(package_inclusions: { access_type: :unlimited })
    }
    scope :with_session_limits, -> {
      joins(:package_inclusions).where.not(package_inclusions: { session_limit: nil })
    }
  end

  def included_products
    products.joins(:package_inclusions)
      .select("products.*, package_inclusions.access_type, package_inclusions.session_limit")
  end

  def unlimited_products
    products.joins(:package_inclusions)
      .where(package_inclusions: { access_type: :unlimited })
  end

  def session_limited_products
    products.joins(:package_inclusions)
      .where.not(package_inclusions: { session_limit: nil })
  end

  def inclusion_for(product)
    package_inclusions.find_by(product: product)
  end

  def includes_product?(product)
    products.include?(product)
  end

  def product_access_type(product)
    inclusion_for(product)&.access_type || :none
  end

  def product_session_limit(product)
    inclusion_for(product)&.session_limit
  end

  def create_registrations_for!(member, user)
    transaction do
      package_inclusions.includes(:product, product: :pricing_plans).map do |inclusion|
        Registration.create!(
          member: member,
          user: user,
          product: inclusion.product,
          pricing_plan: inclusion.product.active_pricing_plans.first,
          package: self,
          start_date: Date.current,
          end_date: calculate_end_date(Date.current),
          billing_period_start: Date.current,
          billing_period_end: calculate_end_date(Date.current),
          amount_paid: 0, # Already paid for package
          sessions_remaining: inclusion.session_limit,
          status: :active
        )
      end
    end
  end
end
