class Product < ApplicationRecord
  include Discard::Model

  has_many :pricing_plans, dependent: :destroy
  has_many :package_inclusions, dependent: :destroy
  has_many :packages, through: :package_inclusions
  has_many :waitlists, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false, conditions: -> { kept } }

  # Metodi
  def current_enrollment
    # Trova tutti gli abbonamenti attivi per questo prodotto
    AccessGrant.active
      .joins(:pricing_plan)
      .where(pricing_plans: { product_id: self.id })
      .count
  end

  def spots_available?
    return true if max_capacity.blank?
    current_enrollment < max_capacity
  end
end
