class Subscription < ApplicationRecord
  before_validation :set_end_date, on: :create

  belongs_to :user
  belongs_to :staff
  belongs_to :activity, optional: true
  belongs_to :subscription_type

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, dependent: :nullify

  enum state: [:attivo, :scaduto]
  after_initialize :set_default_state, :if => :new_record?
  def set_default_state
    self.state ||= :attivo
  end

  validates :start_date, :end_date, :subscription_type, :state, presence: true
  validate :start_date_geq_than_end_date
  validate :when_start_date_end_date_needed
  validate :annual_membership_paid?, if: :activity_subscription?

  scope :active, -> { where(state: :active) }

  def start_date_geq_than_end_date
    if self.start_date.present? && self.end_date.present?
      errors.add(:start_date, "can't be greater than end_date") if start_date >= end_date
    end
  end

  def when_start_date_end_date_needed
    if self.start_date.present? && !self.end_date.present?
      errors.add(:end_date, "when start_date, end_date needed")
    elsif !self.start_date.present? && self.end_date.present?
      errors.add(:start_date, "when end_date, start_date needed")
    end
  end

  private

  def set_end_date
    self.end_date = start_date + subscription_type.duration.days if start_date && subscription_type
  end

  def activity_subscription?
    activity.present?
  end

  def annual_membership_paid?
    unless user && user.has_active_annual_membership?
      errors.add(:base, "You must have an active annual membership to enroll in a activity.")
    end
  end
end
