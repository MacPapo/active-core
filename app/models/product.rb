# frozen_string_literal: true

# Product Model
class Product < ApplicationRecord
  include Discard::Model

  include ProductCatalog, MembershipRequirements, CapacityManagement
  include PricingIntegration

  # Associations
  has_many :pricing_plans, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :package_inclusions, dependent: :destroy
  has_many :packages, through: :package_inclusions
  has_many :waitlists, dependent: :destroy
  has_many :members, through: :registrations

  has_many :active_registrations, -> { active }, class_name: "Registration"
  has_many :active_pricing_plans, -> { active }, class_name: "PricingPlan"

  # Through associations for easier querying
  has_many :members, through: :registrations
  has_many :active_registrations, -> { where(status: :active) }, class_name: "Registration"
  has_many :active_members, through: :active_registrations, source: :member

  accepts_nested_attributes_for :pricing_plans,
                                allow_destroy: true,
                                reject_if: :all_blank

  # Scopes specific to Product
  scope :popular, -> {
    joins(:registrations)
      .group(:id)
      .order("COUNT(registrations.id) DESC")
  }

  # Callbacks
  after_discard :handle_active_registrations

  private

  def handle_active_registrations
    # Business logic: what happens to active registrations when product is deleted?
    active_registrations.update_all(status: :cancelled)
  end
end
