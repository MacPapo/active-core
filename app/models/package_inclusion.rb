# frozen_string_literal: true

# PackageInclusion Model
class PackageInclusion < ApplicationRecord
  belongs_to :package
  belongs_to :product

  validates :access_type, presence: true
  validates :package_id, uniqueness: { scope: :product_id,
                                       message: "Product already included in this package" }
  validates :session_limit, numericality: { greater_than: 0, presence: true },
            if: :limited_sessions?
  validates :session_limit, absence: true, unless: :limited_sessions?
  validate :product_cannot_be_membership_type

  enum :access_type, {
         unlimited: 0,
         limited_sessions: 1,
         time_based: 2
       }, prefix: true

  scope :with_session_limits, -> { where(access_type: :limited_sessions) }
  scope :unlimited_access, -> { where(access_type: :unlimited) }
  scope :time_based_access, -> { where(access_type: :time_based) }
  scope :for_product, ->(product) { where(product: product) }
  scope :for_package, ->(package) { where(package: package) }

  def unlimited_access?
    access_type_unlimited?
  end

  def limited_sessions?
    access_type_limited_sessions?
  end

  def time_based_access?
    access_type_time_based?
  end

  def access_description
    case access_type
    when "unlimited"
      "Unlimited access"
    when "limited_sessions"
      "#{session_limit} sessions"
    when "time_based"
      "Time-based access"
    end
  end

  def can_create_registration?
    product.active? && package.active?
  end

  def initial_sessions_for_registration
    limited_sessions? ? session_limit : nil
  end

  private

  def product_cannot_be_membership_type
    return unless product&.product_type == "membership"

    errors.add(:product, "Membership products cannot be included in packages")
  end
end
