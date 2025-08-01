module SalesManagement
  extend ActiveSupport::Concern

  included do
    validates :max_sales, comparison: { greater_than: 0 }, allow_blank: true

    scope :limited_sales, -> { where.not(max_sales: nil) }
    scope :unlimited_sales, -> { where(max_sales: nil) }
    scope :available_for_sale, -> {
      left_joins(:package_purchases)
        .group(:id)
        .having("packages.max_sales IS NULL OR COUNT(package_purchases.id) < packages.max_sales")
    }
    scope :sold_out, -> {
      joins(:package_purchases)
        .where.not(max_sales: nil)
        .group(:id)
        .having("COUNT(package_purchases.id) >= packages.max_sales")
    }
  end

  def has_sales_limit?
    max_sales.present?
  end

  def unlimited_sales?
    !has_sales_limit?
  end

  def current_sales_count
    package_purchases.count
  end

  def remaining_sales
    return Float::INFINITY if unlimited_sales?
    [ max_sales - current_sales_count, 0 ].max
  end

  def sold_out?
    has_sales_limit? && current_sales_count >= max_sales
  end

  def available_for_purchase?
    active? && currently_valid? && !sold_out?
  end

  def sales_progress_percentage
    return 0 if unlimited_sales?
    (current_sales_count.to_f / max_sales * 100).round(1)
  end
end
