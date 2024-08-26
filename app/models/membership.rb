# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  validates :start_date, presence: true
  validates :end_date, comparison: { greater_than: :start_date }, if: -> { start_date.present? && end_date.present? }

  before_validation :set_dates

  after_save -> { ValidateMembershipStatusJob.perform_later }
  after_destroy -> { AfterDeleteMembershipCleanupSubsJob.perform_later }

  belongs_to :user
  belongs_to :staff

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum :status, %i[inactive active expired], default: :inactive

  MEMBERSHIP_COST = 35.0

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
