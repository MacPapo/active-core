class Package < ApplicationRecord
  include Discard::Model

  # --- ASSOCIATIONS ---
  has_many :package_inclusions, dependent: :destroy
  has_many :products, through: :package_inclusions

  # A package can be sold many times via AccessGrants
  has_many :access_grants, dependent: :restrict_with_error

  # --- ENUMS (Consistent with PricingPlan) ---
  enum duration_unit: { day: 0, week: 1, month: 2, year: 3 }

  # --- VALIDATIONS ---
  validates :name, :duration_interval, :duration_unit, :price, presence: true
  validates :name, uniqueness: { conditions: -> { kept } }
  validates :price, :affiliated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_interval, numericality: { only_integer: true, greater_than: 0 }
  validates :max_sales, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # --- METHODS ---
  def sold_out?
    return false if max_sales.blank?
    access_grants.kept.count >= max_sales
  end

  # Same exact methods as PricingPlan! Reusability for the win.
  def calculate_end_date(start_date)
    return nil unless start_date.is_a?(Date)
    start_date + duration_interval.send(duration_unit)
  end

  def price_for(member)
    member.affiliated? && affiliated_price.present? ? affiliated_price : price
  end

  def available_for_sale?
    !sold_out? && kept? && (valid_from.nil? || valid_from <= Date.current) && (valid_until.nil? || valid_until >= Date.current)
  end
end
