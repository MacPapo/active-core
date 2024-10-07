# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  include Discard::Model

  validates :start_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }

  before_validation :set_dates

  after_save -> { ValidateMembershipStatusJob.perform_later }
  after_destroy -> { AfterDeleteMembershipCleanupSubsJob.perform_later }

  after_discard do
    user&.subscriptions&.discard_all
    payments&.discard_all
  end

  after_undiscard do
    user&.subscriptions&.undiscard_all
    payments&.undiscard_all
  end

  belongs_to :user, touch: true
  belongs_to :staff, touch: true

  has_many :payments, as: :payable, dependent: :destroy

  enum :status, { inactive: 0, active: 1, expired: 2 }, default: :inactive

  MEMBERSHIP_COST = 35.0

  scope :by_name, ->(query) do
    return if query.blank?

    where(
      'name LIKE :q OR surname LIKE :q OR (surname LIKE :s AND name LIKE :n)',
      q: "%#{query}%",
      s: "%#{query.split.last}%",
      n: "%#{query.split.first}%"
    )
  end

  scope :by_interval, ->(from = nil, to = nil) do
    return if from.blank? && to.blank?

    # TODO watch this
    if from.present? && to.present?
      where('memberships.start_date': from..to, 'memberships.end_date': from..to)
    elsif from.present?
      where('memberships.start_date >= ?', from)
    else
      where('memberships.end_date <= ?', to)
    end
  end

  scope :sorted, ->(sort_by, direction) do
    if %w[name surname start_date end_date updated_at].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : 'asc'
      sort_by =
        if %w[name surname].include?(sort_by)
          "users.#{sort_by}"
        else
          "memberships.#{sort_by}"
        end

      order("#{sort_by} #{direction}")
    end
  end

  scope :order_by_updated_at, -> { order('memberships.updated_at desc') }

  def self.filter(params)
    case params[:visibility]
    when 'all'
      all
    when 'deleted'
      discarded
    else
      kept
    end.joins(:user)
      .by_name(params[:name])
      .by_interval(params[:from], params[:to])
      .sorted(params[:sort_by], params[:direction])
  end

  def cost
    MEMBERSHIP_COST
  end

  def humanize_status(status = self.status)
    Membership.human_attribute_name("status.#{status}")
  end

  def num_of_days_til_renewal
    (end_date - Time.zone.today).to_i
  end

  def summary
    "#{self.class.model_name.human} (#{I18n.l(start_date)} al #{I18n.l(end_date)})"
  end

  private

  def set_dates
    set_default_date
    set_end_date_if_blank
  end

  def set_default_date
    self.start_date ||= Time.zone.today
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present?

    self.end_date = Date.new((self.start_date + 1.year).year, 9, 1)
  end
end
