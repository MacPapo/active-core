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

  scope :by_name, ->(name) { where('users.name LIKE ?', "%#{name}%") if name.present? }
  scope :by_surname, ->(surname) { where('users.surname LIKE ?', "%#{surname}%") if surname.present? }
  scope :order_by_updated_at, ->(direction) { order("memberships.updated_at #{direction&.upcase}") }

  MEMBERSHIP_COST = 35.0

  def self.filter(name, surname, direction)
    joins(:user).by_name(name).by_surname(surname).order_by_updated_at(direction)
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
