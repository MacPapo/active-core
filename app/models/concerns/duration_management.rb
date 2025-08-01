module DurationManagement
  extend ActiveSupport::Concern

  included do
    enum :duration_type, { days: 0, weeks: 1, months: 2, years: 3 },
         validate: true

    validates :duration_value, comparison: { greater_than: 0 },
              presence: true
    validates :duration_type, presence: true

    scope :short_term, -> { where(duration_type: [ :days, :weeks ]) }
    scope :long_term, -> { where(duration_type: [ :months, :years ]) }
    scope :by_duration, ->(type) { where(duration_type: type) if type.present? }
  end

  def duration_in_days
    case duration_type
    when "days" then duration_value
    when "weeks" then duration_value * 7
    when "months" then duration_value * 30
    when "years" then duration_value * 365
    end
  end

  def duration_description
    "#{duration_value} #{duration_type.singularize.humanize.downcase}#{'s' if duration_value > 1}"
  end

  def short_term?
    duration_type.in?(%w[days weeks])
  end

  def calculate_end_date(start_date)
    start_date + duration_in_days.days
  end
end
