# frozen_string_literal: true

# Registration Model
class Registration < ApplicationRecord
  include Discard::Model

  # Associations
  belongs_to :user
  belongs_to :member
  belongs_to :product
  belongs_to :pricing_plan
  belongs_to :package, optional: true
  has_many :payment_items, as: :payable, dependent: :destroy

  # Enums
  enum :status, {
    active: 0,
    completed: 1,
    cancelled: 2,
    suspended: 3,
    expired: 4
  }, prefix: true

  # Validations
  validates :start_date, :end_date, :billing_period_start, :billing_period_end, presence: true
  validates :amount_paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sessions_remaining, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :end_date, comparison: { greater_than: :start_date }
  validates :billing_period_end, comparison: { greater_than: :billing_period_start }

  # Scopes
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :expired, -> { where("end_date < ?", Date.current) }
  scope :with_sessions, -> { where.not(sessions_remaining: nil) }
  scope :unlimited_sessions, -> { where(sessions_remaining: nil) }
  scope :by_member, ->(member) { where(member: member) }
  scope :by_product, ->(product) { where(product: product) }
  scope :from_package, -> { where.not(package: nil) }
  scope :direct_purchase, -> { where(package: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :set_billing_periods, if: :new_record?
  before_validation :set_sessions_remaining, if: :new_record?
  after_create :remove_from_waitlist
  after_update :check_completion_status, if: :saved_change_to_sessions_remaining?

  # Instance methods
  def current?
    Date.current.between?(start_date, end_date) && status_active?
  end

  def expired?
    end_date < Date.current || status_expired?
  end

  def has_sessions?
    sessions_remaining.present? && sessions_remaining > 0
  end

  def unlimited_sessions?
    sessions_remaining.nil?
  end

  def can_attend?
    current? && (unlimited_sessions? || has_sessions?)
  end

  def use_session!
    return false unless can_attend? && sessions_remaining.present?

    decrement!(:sessions_remaining)
    check_completion_status
    true
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.current).to_i
  end

  def from_package?
    package.present?
  end

  def duration_in_days
    (end_date - start_date).to_i + 1
  end

  private

  def set_billing_periods
    return unless pricing_plan&.duration_type && pricing_plan&.duration_value

    self.billing_period_start = start_date
    case pricing_plan.duration_type
    when "days"
      self.billing_period_end = start_date + (pricing_plan.duration_value - 1).days
    when "months"
      self.billing_period_end = start_date + pricing_plan.duration_value.months - 1.day
    when "years"
      self.billing_period_end = start_date + pricing_plan.duration_value.years - 1.day
    end
  end

  def set_sessions_remaining
    return unless package&.package_inclusions

    inclusion = package.package_inclusions.find_by(product: product)
    return unless inclusion

    case inclusion.access_type
    when "limited"
      self.sessions_remaining = inclusion.session_limit
    when "unlimited"
      self.sessions_remaining = nil
    end
  end

  def remove_from_waitlist
    member.waitlists.where(product: product).destroy_all
  end

  def check_completion_status
    if sessions_remaining == 0
      update!(status: :completed)
    end
  end
end
