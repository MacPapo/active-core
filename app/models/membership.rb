# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  include Discard::Model

  # Associations
  belongs_to :user
  belongs_to :member
  belongs_to :pricing_plan
  belongs_to :renewed_from, class_name: "Membership", optional: true
  has_many :renewals, class_name: "Membership", foreign_key: "renewed_from_id", dependent: :nullify
  has_many :payment_items, as: :payable, dependent: :destroy

  # Enums
  enum :status, {
         active: 0,
         expired: 1,
         cancelled: 2,
         suspended: 3
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
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :set_billing_periods, if: :new_record?
  after_create :update_member_status
  after_update :update_member_status, if: :saved_change_to_status?

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

  def renewal?
    renewed_from.present?
  end

  def can_renew?
    status_active? && days_remaining <= 30
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

  def update_member_status
    # Update member's affiliated status based on active memberships
    member.update!(
      affiliated: member.memberships.kept.status_active.current.exists?
    )
  end
end
