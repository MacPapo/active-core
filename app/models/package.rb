# frozen_string_literal: true

# Package Model
class Package < ApplicationRecord
  include Discard::Model

  include ValidityPeriod
  include DurationManagement
  include Pricing::Pricable
  include Package::SalesManagement
  include Package::Analytics, Package::BundleManagement, Package::InclusionManagement

  # Associations
  has_many :package_inclusions, dependent: :destroy
  has_many :products, through: :package_inclusions
  has_many :package_purchases, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :members, through: :package_purchases

  accepts_nested_attributes_for :package_inclusions, allow_destroy: true, reject_if: :all_blank

  # Active scope combining multiple concerns
  scope :active, -> { where(active: true).currently_valid.available_for_sale }

  # Callbacks
  after_create :validate_inclusions
  before_destroy :handle_active_purchases

  def display_name
    savings = savings_amount
    base = "#{name} - €#{price}"
    savings > 0 ? "#{base} (Save €#{savings})" : base
  end

  def purchase_for!(member:, user:)
    raise "Package not available" unless available_for_purchase?
    raise "Member not eligible" unless member.medical_certificate_valid?

    transaction do
      purchase = package_purchases.create!(
        member: member,
        user: user,
        start_date: Date.current,
        end_date: calculate_end_date(Date.current),
        billing_period_start: Date.current,
        billing_period_end: calculate_end_date(Date.current),
        status: :active
      )

      create_registrations_for!(member, user)
      purchase
    end
  end

  private

  def validate_inclusions
    errors.add(:base, "Package must include at least one product") if products.empty?
  end

  def handle_active_purchases
    package_purchases.active.update_all(status: :cancelled)
  end
end
