module Terminable
  extend ActiveSupport::Concern

  included do
    enum :status, { pending: 0, active: 1, expired: 2, cancelled: 3, suspended: 4 },
         validate: true

    validates :start_date, :end_date, presence: true
    validates :end_date, comparison: { greater_than: :start_date }
    validates :amount_paid, comparison: { greater_than_or_equal_to: 0 },
              presence: true

    scope :current, -> { where(start_date: ..Date.current, end_date: Date.current..) }
    scope :expired_recently, -> { where(end_date: 1.month.ago..Date.current) }
    scope :expiring_soon, -> { where(end_date: Date.current..1.week.from_now) }
    scope :by_period, ->(from, to) { where(start_date: from..to) }
  end

  def current?
    active? && Date.current.between?(start_date, end_date)
  end

  def expired?
    end_date < Date.current
  end

  def expires_soon?(days = 7)
    active? && end_date <= days.days.from_now && end_date >= Date.current
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.current).to_i
  end

  def duration_in_days
    (end_date - start_date).to_i + 1
  end

  def progress_percentage
    return 100 if expired?
    days_passed = (Date.current - start_date).to_i
    (days_passed.to_f / duration_in_days * 100).round(1)
  end
end
