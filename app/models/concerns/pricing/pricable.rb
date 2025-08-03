module Pricing::Pricable
  extend ActiveSupport::Concern

  included do
    validates :price, numericality: { greater_than_or_equal_to: 0, presence: true }
    validates :affiliated_price, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

    scope :with_affiliated_discount, -> { where("affiliated_price IS NOT NULL AND affiliated_price < price") }
  end

  def has_affiliated_discount?
    affiliated_price.present? && affiliated_price < price
  end

  def price_for(member)
    member&.affiliated? && has_affiliated_discount? ? affiliated_price : price
  end

  def discount_percentage
    return 0 unless has_affiliated_discount? && price.positive?
    ((price - affiliated_price) / price * 100).round(1)
  end
end
