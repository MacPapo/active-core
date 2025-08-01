module BundleManagement
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true, length: { in: 1..200 },
              uniqueness: { case_sensitive: false, conditions: -> { where(discarded_at: nil) } }
    validates :description, length: { maximum: 1000 }, allow_blank: true
    validates :price, comparison: { greater_than_or_equal_to: 0 }, presence: true
    validates :affiliated_price, comparison: { greater_than_or_equal_to: 0 },
              allow_blank: true

    normalizes :name, with: -> { _1&.titleize&.strip }

    scope :with_discount, -> { where("affiliated_price IS NOT NULL AND affiliated_price < price") }
    scope :by_price_range, ->(min, max) { where(price: min..max) }
    scope :popular, -> {
      joins(:package_purchases)
        .group(:id)
        .order("COUNT(package_purchases.id) DESC")
    }
  end

  def has_affiliated_discount?
    affiliated_price.present? && affiliated_price < price
  end

  def price_for(member)
    member&.affiliated? && has_affiliated_discount? ? affiliated_price : price
  end

  def discount_percentage
    return 0 unless has_affiliated_discount?
    ((price - affiliated_price) / price * 100).round(1)
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
