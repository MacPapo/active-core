module ServiceLifecycle
  extend ActiveSupport::Concern

  included do
    validates :start_date, :end_date, presence: true
    validates :end_date, comparison: { greater_than_or_equal_to: :start_date }

    scope :currently_valid, -> {
      where(start_date: ..Date.current, end_date: Date.current..)
    }
    scope :expired, -> { where("end_date < ?", Date.current) }
    scope :future, -> { where("start_date > ?", Date.current) }
    scope :expiring_soon, ->(days = 7) { where(end_date: Date.current..days.days.from_now) }
  end

  def currently_valid?
    Date.current.between?(start_date, end_date)
  end

  def expired?
    end_date < Date.current
  end

  def expires_soon?(days = 7)
    currently_valid? && end_date <= days.days.from_now
  end

  def days_remaining
    return 0 if expired?
    (end_date - Date.current).to_i
  end
end
