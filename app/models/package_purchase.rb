# frozen_string_literal: true

# PackagePurchase Model
class PackagePurchase < ApplicationRecord
  include Discard::Model

  # Associations
  belongs_to :member
  belongs_to :package
  belongs_to :user
  has_many :payment_items, as: :payable, dependent: :destroy
  has_many :registrations, dependent: :nullify

  # Enums
  enum :status, {
         active: 0,
         used: 1,
         expired: 2,
         cancelled: 3
       }, prefix: true

  # Validations
  validates :start_date, :end_date, :billing_period_start, :billing_period_end, presence: true
  validates :amount_paid, presence: true, numericality: { greater_than: 0 }
  validates :end_date, comparison: { greater_than: :start_date }
  validates :billing_period_end, comparison: { greater_than: :billing_period_start }

  # Scopes
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :expired, -> { where("end_date < ?", Date.current) }
  scope :expiring_soon, ->(days = 7) { where(end_date: Date.current..(Date.current + days.days)) }
  scope :by_member, ->(member) { where(member: member) }
  scope :by_package, ->(package) { where(package: package) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :set_billing_periods, if: :new_record?
  after_create :create_initial_registrations

  # Instance methods
  def current?
    Date.current.between?(start_date, end_date) && status_active?
  end

  def expired?
    end_date < Date.current || status_expired?
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.current).to_i
  end

  def fully_used?
    return false unless package.package_inclusions.exists?

    package.package_inclusions.all? do |inclusion|
      next true if inclusion.access_type == "unlimited"

      used_sessions = registrations.where(product: inclusion.product).sum do |registration|
        if registration.sessions_remaining.nil?
          0 # unlimited sessions don't count as "used"
        else
          (inclusion.session_limit || 0) - (registration.sessions_remaining || 0)
        end
      end

      used_sessions >= (inclusion.session_limit || 0)
    end
  end

  def can_register_for?(product)
    return false unless current?

    inclusion = package.package_inclusions.find_by(product: product)
    return false unless inclusion

    case inclusion.access_type
    when "unlimited"
      true
    when "limited"
      remaining_sessions_for(product) > 0
    else
      false
    end
  end

  def remaining_sessions_for(product)
    inclusion = package.package_inclusions.find_by(product: product)
    return 0 unless inclusion&.session_limit

    used_sessions = registrations.where(product: product).sum do |registration|
      next 0 if registration.sessions_remaining.nil?
      inclusion.session_limit - registration.sessions_remaining
    end

    [ inclusion.session_limit - used_sessions, 0 ].max
  end

  def duration_in_days
    (end_date - start_date).to_i + 1
  end

  def included_products
    package.products.distinct
  end

  def usage_summary
    package.package_inclusions.map do |inclusion|
      {
        product: inclusion.product,
        access_type: inclusion.access_type,
        total_limit: inclusion.session_limit,
        remaining: remaining_sessions_for(inclusion.product)
      }
    end
  end

  private

  def set_billing_periods
    return unless package&.duration_type && package&.duration_value

    self.billing_period_start = start_date
    case package.duration_type
    when "days"
      self.billing_period_end = start_date + (package.duration_value - 1).days
    when "months"
      self.billing_period_end = start_date + package.duration_value.months - 1.day
    when "years"
      self.billing_period_end = start_date + package.duration_value.years - 1.day
    end
  end

  def create_initial_registrations
    # This method intentionally left empty
    # Registrations will be created separately when member actually registers for activities
    # This allows for more flexible usage patterns
  end
end
