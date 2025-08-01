module PricingLogic
  extend ActiveSupport::Concern

  included do
    validates :price, comparison: { greater_than_or_equal_to: 0 },
              presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :affiliated_price, comparison: { greater_than_or_equal_to: 0 },
              allow_blank: true

    scope :free, -> { where(price: 0) }
    scope :paid, -> { where(price: 0.01..) }
    scope :by_price_range, ->(min, max) { where(price: min..max) }
    scope :affordable, -> { where(price: ..50) }
    scope :premium, -> { where(price: 100..) }
  end

  def free?
    price.zero?
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

  def daily_cost
    (price / duration_in_days).round(2)
  end
end
