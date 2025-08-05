module Package::Analytics
  extend ActiveSupport::Concern

  included do
    scope :most_profitable, -> {
      joins(package_purchases: { payment_items: :payment })
        .group("packages.id")
        .order("SUM(payments.final_amount) DESC")
    }
    scope :by_purchase_period, ->(from, to) {
      joins(:package_purchases).where(package_purchases: { created_at: from..to })
    }
  end

  def total_revenue
    Payment.joins(payment_items: :payable)
      .where(payment_items: { payable_type: "PackagePurchase", payable_id: self.package_purchase_ids })
      .sum(:final_amount)
  end

  def average_revenue
    Payment.joins(payment_items: :payable)
      .where(payment_items: { payable_type: "PackagePurchase", payable_id: self.package_purchase_ids })
      .average(:final_amount)&.round(2) || 0
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
