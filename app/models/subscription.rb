class Subscription < ApplicationRecord
  # TODO remove this!
  before_validation :set_start_date
  before_validation :set_end_date_if_blank

  belongs_to :user
  belongs_to :staff
  belongs_to :activity
  belongs_to :activity_plan

  has_one :normal_subscription, class_name: 'Subscription', foreign_key: "open_subscription_id", dependent: :destroy
  belongs_to :open_subscription, class_name: 'Subscription', optional: true, dependent: :destroy

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum :status, [ :inactive, :active, :expired ], default: :inactive

  validates :start_date, :activity, :activity_plan, :user, :staff, presence: true
  validate :annual_membership_paid?, if: :activity_subscription?

  scope :active, -> { where(status: :active) }

  OPEN_COST = 30.0

  def cost
    self.activity_plan.cost
  end

  def affiliated_cost
    self.activity_plan.affiliated_cost
  end

  def get_cost
    acost =
      if self.user.affiliated? && affiliated_cost
        affiliated_cost
      else
        cost
      end

    self.open? ? acost + OPEN_COST : acost
  end

  def get_status
    self.status.to_sym
  end

  def open?
    self.open_subscription.present? || self.normal_subscription.present?
  end

  def days_til_renewal
    return -1 if self.start_date.nil? || self.end_date.nil?

    (self.end_date - Date.today).to_i
  end

  private

  def set_start_date
    if self.start_date && self.activity_plan
      plan = activity_plan
      sdate = self.start_date.to_date

      if (plan.half_month? && sdate.after?(sdate.at_beginning_of_month + 11.day))
        self.start_date = self.start_date.beginning_of_month + 14.day
      elsif (!plan.one_entrance?)
        self.start_date = self.start_date.beginning_of_month
      end
    end
  end

  def set_end_date_if_blank
    if self.end_date.blank? && self.start_date.present? && activity_plan
      self.end_date = plan_handler(activity_plan)
    end
  end

  def activity_subscription?
    activity.present?
  end

  def annual_membership_paid?
    unless user && user.has_active_membership?
      errors.add(:base, I18n.t('global.errors.no_mem'))
    end
  end

  def plan_handler(activity_plan)
    plan = activity_plan.get_plan

    case plan
    when :one_entrance
      start_date
    when :half_month
      half_month_handler(start_date)
    when :one_month, :one_month_one_lesson, :one_month_two_lessons
      start_date.at_end_of_month
    when :three_months
      start_date.months_since(2).at_end_of_month
    when :one_year
      self.start_date.at_end_of_year
    else
      '1970-01-01'
    end
  end

  def half_month_handler(start_date)
    if start_date == (start_date.beginning_of_month + 14.day)
      start_date.at_end_of_month
    else
      start_date + 14.days
    end
  end
end
