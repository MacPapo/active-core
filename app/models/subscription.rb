class Subscription < ApplicationRecord
  # before_validation :set_end_date, on: :create

  belongs_to :user
  belongs_to :staff
  belongs_to :activity
  belongs_to :activity_plan

  has_many :subscription_histories, dependent: :destroy
  has_many :payments, as: :payable, dependent: :nullify

  enum state: [:attivo, :scaduto]
  after_initialize :set_default_state, if: :new_record?

  validates :start_date, :end_date, :state, presence: true
  validate :annual_membership_paid?, if: :activity_subscription?

  scope :active, -> { where(state: :active) }

  private

  # TODO
  # def set_end_date
  #   self.end_date = start_date + nsubscription_type.duration.days if start_date && subscription_type
  # end

  def set_default_state
    self.state ||= :attivo
  end

  def activity_subscription?
    activity.present?
  end

  def annual_membership_paid?
    unless user && user.has_active_membership?
      errors.add(:base, "You must have an active annual membership to enroll in an activity.")
    end
  end
end
