# frozen_string_literal: true

# Subscription Model
class Subscription < ApplicationRecord
  include Discard::Model

  validates :start_date, :activity_id, :activity_plan_id, :user_id, :staff_id, presence: true
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, if: -> { start_date.present? && end_date.present? }

  # validate :date_valid_for_membership?, if: -> { user&.membership&.active? }

  delegate :cost, :affiliated_cost, prefix: "plan", to: :activity_plan
  delegate :active_membership?, to: :user

  # TODO
  before_validation :set_end_date_if_blank
  after_validation  :set_start_date, if: -> { will_save_change_to_attribute?("start_date") }

  after_save -> { ValidateSubscriptionStatusJob.perform_later }

  belongs_to :user, touch: true
  belongs_to :staff, touch: true
  belongs_to :activity, touch: true
  belongs_to :activity_plan

  belongs_to :open_subscription, inverse_of: :normal_subscription, class_name: "Subscription", optional: true, dependent: :destroy

  has_one :normal_subscription, inverse_of: :open_subscription, class_name: "Subscription", foreign_key: "open_subscription_id", dependent: :destroy

  has_many :payment_subscriptions, dependent: :destroy
  has_many :receipt_subscriptions, dependent: :destroy

  has_many :payments, through: :payment_subscriptions
  has_many :receipts, through: :receipt_subscriptions

  after_discard do
    open_subscription&.discard
    payments&.discard_all
    receipts&.discard_all
  end

  after_undiscard do
    user&.membership&.undiscard
    open_subscription&.undiscard
    payments&.undiscard_all
    receipts&.undiscard_all
  end

  enum :status, { inactive: 0, active: 1, expired: 2 }, default: :inactive

  OPEN_COST = 30.0

  scope :by_name, ->(query) do
    if query.present?
      where("users.name LIKE :q OR users.surname LIKE :q OR (users.surname LIKE :s AND users.name LIKE :n)", q: "%#{query}%", s: "%#{query.split.last}%", n: "%#{query.split.first}%")
    end
  end

  scope :by_activity_id, ->(id) do
    return if id.blank?

    where("subscriptions.activity_id = ?", id.to_i)
  end

  scope :by_open, ->(open) do
    open = ActiveModel::Type::Boolean.new.cast(open)
    return if open.nil?

    open ? where.associated(:open_subscription) : where.missing(:open_subscription)
  end

  scope :by_interval, ->(from = nil, to = nil) do
    return if from.blank? && to.blank?

    if from.blank?
      end_date = DateTime.parse(to).end_of_day
      where('subscriptions.created_at': ..end_date)
    elsif to.blank?
      where('subscriptions.created_at': from..)
    else
      end_date = to.is_a?(String) ? DateTime.parse(to).end_of_day : to
      where('subscriptions.created_at': from..end_date)
    end
  end

  scope :by_activity_name, ->(name) do
    return if name.blank?

    joins(:activity).where("activities.name LIKE ?", "%#{name}%")
  end

  scope :by_plan_id, ->(id) { where("subscriptions.activity_plan_id" => ActivityPlan.where(plan: id).pluck(:id)) unless id.blank? }

  scope :sorted, ->(sort_by, direction) do
    if %w[name surname activity_name start_date end_date updated_at].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : "asc"

      res =
        case sort_by
        when "name", "surname"
          "users.#{sort_by}"
        when "activity_name"
          "activities.name"
        else
          "subscriptions.#{sort_by}"
        end

      order("#{res} #{direction}")
    end
  end

  def self.filter(params)
    case params[:visibility]
    when "all"
      all
    when "deleted"
      discarded
    else
      kept
    end.joins(:user)
      .by_name(params[:name])
      .by_activity_id(params[:activity])
      .by_plan_id(params[:plan])
      .by_open(params[:open])
      .by_interval(params[:from], params[:to])
      .sorted(params[:sort_by], params[:direction])
  end

  def self.humanize_statuses(keys = statuses.keys)
    keys.map do |key|
      [ Subscription.human_attribute_name("status.#{key}"), key ]
    end
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
    "#{I18n.t('receipts.subscription')} - #{activity.name} (#{activity_plan.humanize_plan}) #{open? ? 'OPEN' : ''} (#{I18n.l(start_date)} al #{I18n.l(end_date)})"
  end

  private

  def set_start_date
    return if activity_plan.blank? || activity_plan.one_entrance?

    sd = start_date

    self.start_date = sd.at_beginning_of_month.to_date
    return unless activity_plan.half_month?

    self.start_date += 14.days if activity_plan.half_month? && sd.day > 14
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present? && activity_plan

    self.end_date = plan_handler(activity_plan)
  end

  def plan_handler(activity_plan)
    return start_date if activity_plan.one_entrance?

    case activity_plan
    when -> { _1.one_year? }
      user.membership&.end_date
    when -> { _1.three_months? }
      start_date.months_since(2).at_end_of_month
    else
      months_handler(activity_plan)
    end
  end

  def months_handler(plan)
    return half_month_handler if plan.half_month?

    start_date.at_end_of_month.to_date
  end

  def half_month_handler
    date = start_date
    half = (date.beginning_of_month + 14.days).to_date

    date <= half ? half : start_date.at_end_of_month.to_date
  end

  # FIX THIS
  def date_valid_for_membership?
    end_date < user.membership.end_date
  end
end
