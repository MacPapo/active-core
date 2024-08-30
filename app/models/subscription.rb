# frozen_string_literal: true

# Subscription Model
class Subscription < ApplicationRecord
  validates :start_date, :activity_id, :activity_plan_id, :user_id, :staff_id, presence: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }
  validate :active_membership?, if: -> { activity.present? }

  delegate :cost, :affiliated_cost, prefix: 'plan', to: :activity_plan
  delegate :active_membership?, to: :user

  before_validation :set_end_date_if_blank
  after_validation :set_start_date

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

  scope :active, -> { where(status: :active) }
  scope :by_name, ->(name) { where('users.name LIKE ?', "%#{name}%") if name.present? }
  scope :by_surname, ->(surname) { where('users.surname LIKE ?', "%#{surname}%") if surname.present? }
  scope :order_by_updated_at, ->(direction) { order("subscriptions.updated_at #{direction&.upcase}") }

  def self.filter(name, surname, direction)
    joins(:user).by_name(name).by_surname(surname).order_by_updated_at(direction)
  end

  OPEN_COST = 30.0

  def humanize_status(status = self.status)
    Subscription.human_attribute_name("status.#{status}")
  end

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

  def summary
    "#{self.class.model_name.human} - #{activity.name} (#{activity_plan.humanize_plan}) #{open? ? 'OPEN' : ''} (#{I18n.l(start_date)} al #{I18n.l(end_date)})"
  end

  private

  def set_start_date
    return if activity_plan.blank? || activity_plan.one_entrance?

    date = start_date

    self.start_date = start_date.beginning_of_month
    return unless activity_plan.half_month?

    self.start_date += 14.days if date.after?(start_date + 11.days)
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present? && activity_plan

    self.end_date = plan_handler(activity_plan)
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
