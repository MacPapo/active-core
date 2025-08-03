# frozen_string_literal: true

# PricingPlan Model
class PricingPlan < ApplicationRecord
  include Discard::Model
  include DurationManagement
  include ValidityPeriod
  include Pricing::Pricable, Pricing::Logic

  # Associations
  belongs_to :product
  has_many :memberships, dependent: :destroy
  has_many :registrations, dependent: :destroy

  # Active scope
  scope :active, -> { kept.where(active: true).currently_valid }

  # Business logic scopes
  scope :most_popular, -> {
    joins(:memberships, :registrations)
      .group(:id)
      .order("COUNT(memberships.id) + COUNT(registrations.id) DESC")
  }

  def display_name
    "#{product.name} - #{duration_description} (€#{price})"
  end
end
