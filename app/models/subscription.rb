# frozen_string_literal: true

# Subscription Model
class Subscription < ApplicationRecord
  before_validation :set_start_date
  before_validation :set_end_date_if_blank

  belongs_to :user
  belongs_to :staff
  belongs_to :activity
  belongs_to :activity_plan

  belongs_to :open_subscription,
             inverse_of: :normal_subscription,
             class_name: 'Subscription',
             optional: true,
             dependent: :destroy

  has_one :normal_subscription,
          inverse_of: :open_subscription,
          class_name: 'Subscription',
          foreign_key: 'open_subscription_id',
          dependent: :destroy

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum :status, %i[inactive active expired], default: :inactive

  validates :start_date, :activity, :activity_plan, :user, :staff, presence: true
  validate :active_membership?, if: :activity_present?

  scope :active, -> { where(status: :active) }

  delegate :cost, :affiliated_cost, prefix: 'plan', to: :activity_plan
  delegate :active_membership?, to: :user

  OPEN_COST = 30.0

  def cost
    acost =
      if user.affiliated? && plan_affiliated_cost
        plan_affiliated_cost
      else
        plan_cost
      end

    open? ? acost + OPEN_COST : acost
  end

  def open?
    open_subscription.present? || normal_subscription.present?
  end

  def days_til_renewal
    return -1 if start_date.blank? || end_date.blank?

    (end_date - Time.zone.today).to_i
  end

  private

  def set_start_date
    p self
    return if activity_plan.one_entrance?

    date = start_date

    self.start_date = start_date.beginning_of_month
    return unless activity_plan.half_month?

    self.start_date += 14.days if date.after?(start_date + 11.days)
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present? && activity_plan

    self.end_date = plan_handler(activity_plan)
  end

  def activity_present?
    activity.present?
  end

  def plan_handler(activity_plan)
    return start_date if activity_plan.one_entrance?

    case activity_plan
    when -> { _1.one_year? }
      start_date.at_end_of_year
    when -> { _1.three_months? }
      start_date.months_since(2).at_end_of_month
    else
      months_handler(activity_plan)
    end
  end

  def months_handler(plan)
    return start_date.at_end_of_month unless plan.half_month?

    half_month_handler
  end

  def half_month_handler
    date = start_date
    half = date.beginning_of_month + 14.days

    date == half ? start_date.at_end_of_month : start_date + 14.days
  end
end
