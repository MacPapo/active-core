# frozen_string_literal: true

# Membership Model
class Membership < ApplicationRecord
  before_validation :set_end_date_if_blank

  after_initialize :set_default_date, if: :new_record?

  after_save    :validate_status
  after_destroy :cleanup_subs

  belongs_to :user
  belongs_to :staff

  has_many :membership_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy

  enum :status, %i[inactive active expired], default: :inactive

  validates :start_date, presence: true

  MEMBERSHIP_COST = 35.0

  def cost
    MEMBERSHIP_COST
  end

  def humanize_status(status = self.status)
    Membership.human_attribute_name("status.#{status}")
  end

  def num_of_days_til_renewal
    (renewal_date - Time.zone.today).to_i
  end

  def renewal_date
    end_date
  end

  private

  def set_default_date
    self.start_date ||= Time.zone.today
  end

  def set_end_date_if_blank
    return unless end_date.blank? && start_date.present?

    self.end_date = Date.new((self.start_date + 1.year).year, 9, 1)
  end

  def validate_status
    ValidateMembershipStatusJob.perform_later
  end

  def cleanup_subs
    AfterDeleteMembershipCleanupSubsJob.perform_later
  end
end
