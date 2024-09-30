# frozen_string_literal: true

# Subscription Model
class Subscription < ApplicationRecord
  validates :start_date, :activity_id, :activity_plan_id, :user_id, :staff_id, presence: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }
  validate :active_membership?, if: -> { user.present? && activity.present? }
  validate :date_valid_for_membership?, if: -> { user&.membership&.active? }

  delegate :cost, :affiliated_cost, prefix: 'plan', to: :activity_plan
  delegate :active_membership?, to: :user

  before_validation :set_end_date_if_blank
  after_validation  :set_start_date, if: -> { will_save_change_to_attribute?('start_date') }

  after_save -> { ValidateSubscriptionStatusJob.perform_later }

  belongs_to :user, touch: true
  belongs_to :staff, touch: true
  belongs_to :activity, touch: true
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

  enum :status, { inactive: 0, active: 1, expired: 2 }, default: :inactive

  OPEN_COST = 30.0

  scope :by_name, ->(query) do
    if query.present?
      where('users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)', q: "%#{query}%", s: "%#{query.split.last}%", n: "%#{query.split.first}%")
    end
  end

  scope :sorted, ->(sort_by, direction) do
    if %w[user_name activity_name surname start_date end_date].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : 'asc'

      if sort_by == 'user_name' || sort_by == 'activity_name'
        sort_by = sort_by == 'user_name' ? 'users.name' : 'activities.name'
      end

      order("#{sort_by} #{direction}")
    end
  end

  scope :order_by_updated_at, -> { order('subscriptions.updated_at desc') }

  def self.filter(name, sort_by, direction)
    joins(:user)
      .by_name(name)
      .sorted(sort_by, direction)
      .order_by_updated_at
  end

  def humanize_status(status = self.status)
    Subscription.human_attribute_name("status.#{status}")
  end

  def cost
    acost = user.affiliated? && plan_affiliated_cost.present? ? plan_affiliated_cost : plan_cost

    open? ? acost + OPEN_COST : acost
  end

  def open?
    open_subscription.present? || normal_subscription.present?
  end

  def days_til_renewal
    return -1 if start_date.blank? || end_date.blank?

    (end_date - Time.zone.today).to_i
  end

  def summary
    "#{self.class.model_name.human} - #{activity.name} (#{activity_plan.humanize_plan}) #{open? ? 'OPEN' : ''} (#{I18n.l(start_date)} al #{I18n.l(end_date)})"
  end

  private

  def set_start_date
    return if activity_plan.blank? || activity_plan.one_entrance?

    date = start_date

    self.start_date = date.beginning_of_month
    return unless activity_plan.half_month?

    self.start_date += 14.days if date.after?(start_date + 14.days)
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present? && activity_plan

    self.end_date = plan_handler(activity_plan)
  end

  def plan_handler(activity_plan)
    return start_date if activity_plan.one_entrance?

    case activity_plan
    when -> { _1.one_year? }
      user.membership.end_date
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

    date <= half ? half : start_date.at_end_of_month
  end

  # FIX THIS
  def date_valid_for_membership?
    end_date < user.membership.end_date
  end
end
