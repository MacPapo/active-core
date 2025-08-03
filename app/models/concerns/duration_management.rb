module DurationManagement
  extend ActiveSupport::Concern

  included do
    enum :duration_type, { days: 0, weeks: 1, months: 2, years: 3 }, validate: true

    validates :duration_value, numericality: { greater_than: 0, presence: true }
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

  # TODO localization
  def duration_description
    I18n.t("duration_type.#{duration_type}", count: duration_value)
  end

  def short_term?
    duration_type.in?(%w[days weeks])
  end

  def calculate_end_date(start_date)
    start_date + duration_in_days.days
  end
end
