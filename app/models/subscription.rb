class Subscription < ApplicationRecord
  before_validation :set_start_date, on: :create
  before_validation :set_end_date, on: :create

  after_initialize :set_default_status, if: :new_record?

  belongs_to :user
  belongs_to :staff
  belongs_to :activity
  belongs_to :activity_plan
  belongs_to :open_activity, class_name: 'Activity', optional: true

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum status: [:inattivo, :attivo, :scaduto]

  validates :start_date, :activity, :activity_plan, :user, :staff, presence: true
  validates :open, inclusion: { in: [true, false] }
  validate :annual_membership_paid?, if: :activity_subscription?

  scope :active, -> { where(status: :attivo) }

  def cost
    self.activity_plan.cost
  end

  def affiliated_cost
    self.activity_plan.affiliated_cost
  end

  def get_status
    self.status.to_sym
  end

  private

  def set_default_status
    self.status ||= :inattivo
  end

  def set_start_date
    if start_date && activity_plan
      plan = activity_plan.get_plan
      sdate = self.start_date.to_date

      if (plan == :half_month && sdate.after?(sdate.at_beginning_of_month + 11.day))
        self.start_date = self.start_date.beginning_of_month + 14.day
      elsif (plan != :one_entrance)
        self.start_date = self.start_date.beginning_of_month
      end
    end
  end

  def set_end_date
    if start_date && activity_plan
      self.end_date = plan_handler(activity_plan)
    end
  end

  def activity_subscription?
    activity.present?
  end

  def annual_membership_paid?
    unless user && user.has_active_membership?
      errors.add(:base, "You must have an active annual membership to enroll in an activity.")
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
