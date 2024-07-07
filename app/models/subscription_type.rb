class SubscriptionType < ApplicationRecord
  has_many :subscriptions

  enum plan: [:half, :one, :three, :year]
  after_initialize :set_default_plan, :if => :new_record?
  def set_default_plan
    self.plan ||= :one
  end


  validates :plan, :duration, :cost, presence: true
  validate :duration_bounderies, if: :duration_present?
  validate :cost_cannot_be_below_0, if: :cost_present?

  def duration_present?
    duration.present?
  end

  def cost_present?
    cost.present?
  end

  def duration_bounderies
    duration_cannot_exceed_one_year
    duration_cannot_be_below_15_days
  end

  def duration_cannot_exceed_one_year
    if duration > 365
      errors.add(:duration, "can't exceed one year!")
    end
  end

  def duration_cannot_be_below_15_days
    if duration < 15
      errors.add(:duration, "can't be below 15 days!")
    end
  end

  def cost_cannot_be_below_0
    if cost < 0
      errors.add(:cost, "can't be below 0")
    end
  end
end
