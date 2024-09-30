# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }

  before_validation :set_dates

  after_save -> { ValidateMembershipStatusJob.perform_later }
  after_destroy -> { AfterDeleteMembershipCleanupSubsJob.perform_later }

  belongs_to :user, touch: true
  belongs_to :staff, touch: true

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum :status, { inactive: 0, active: 1, expired: 2 }, default: :inactive

  MEMBERSHIP_COST = 35.0

  scope :by_name, ->(query) do
    if query.present?
      where(
        'name LIKE :q OR surname LIKE :q OR (surname LIKE :s AND name LIKE :n)',
        q: "%#{query}%",
        s: "%#{query.split.last}%",
        n: "%#{query.split.first}%"
      )
    end
  end

  scope :sorted, ->(sort_by, direction) do
    if %w[name surname start_date end_date].include?(sort_by)
      direction = %w[asc desc].include?(direction) ? direction : 'asc'
      order("#{sort_by} #{direction}")
    end
  end

  scope :order_by_updated_at, -> { order('memberships.updated_at desc') }

  def self.filter(name, sort_by, direction)
    joins(:user)
      .by_name(name)
      .sorted(sort_by, direction)
      .order_by_updated_at
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
