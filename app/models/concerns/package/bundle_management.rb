module Package::BundleManagement
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true, length: { in: 1..200 },
              uniqueness: { case_sensitive: false, conditions: -> { where(discarded_at: nil) } }

    validates :description, length: { maximum: 1000 }, allow_blank: true

    normalizes :name, with: -> { _1&.titleize&.strip }

    scope :popular, -> {
      joins(:package_purchases)
        .group(:id)
        .order("COUNT(package_purchases.id) DESC")
    }
  end

  def total_included_products
    package_inclusions.count
  end

  def bundle_value
    package_inclusions.joins(:product, product: :pricing_plans)
      .where(pricing_plans: { active: true })
      .sum("pricing_plans.price")
  end

  def savings_amount
    [ bundle_value - price, 0 ].max
  end
end
