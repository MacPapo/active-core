module Package::Analytics
  extend ActiveSupport::Concern

  included do
    scope :revenue_generators, -> {
      joins(:package_purchases)
        .group(:id)
        .order("SUM(package_purchases.amount_paid) DESC")
    }
    scope :by_purchase_period, ->(from, to) {
      joins(:package_purchases).where(package_purchases: { created_at: from..to })
    }
  end

  def total_revenue
    package_purchases.sum(:amount_paid)
  end

  def average_purchase_price
    package_purchases.average(:amount_paid)&.round(2) || 0
  end

  def conversion_rate
    # This would need view/interest tracking to be meaningful
    # For now, just return sales vs some baseline
    current_sales_count.to_f
  end

  def most_popular_included_product
    Product
      .joins(package_inclusions: :package_purchases)
      .where(package_purchases: { package_id: id })
      .group("products.id")
      .order("COUNT(package_purchases.id) DESC")
      .first
  end

  def package_utilization
    total_registrations = package_purchases.joins(:registrations).count
    expected_registrations = package_purchases.count * package_inclusions.count
    return 0 if expected_registrations.zero?

    (total_registrations.to_f / expected_registrations * 100).round(1)
  end
end
