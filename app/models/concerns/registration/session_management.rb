module Registration::SessionManagement
  extend ActiveSupport::Concern

  included do
    validates :sessions_remaining, comparison: { greater_than_or_equal_to: 0 },
              allow_blank: true

    scope :with_sessions, -> { where.not(sessions_remaining: nil) }
    scope :unlimited_sessions, -> { where(sessions_remaining: nil) }
    scope :sessions_available, -> { where("sessions_remaining > 0 OR sessions_remaining IS NULL") }
    scope :sessions_exhausted, -> { where(sessions_remaining: 0) }
  end

  def has_session_limit?
    sessions_remaining.present?
  end

  def unlimited_sessions?
    !has_session_limit?
  end

  def sessions_available?
    unlimited_sessions? || sessions_remaining&.positive?
  end

  def sessions_exhausted?
    has_session_limit? && sessions_remaining&.zero?
  end

  def consume_session!
    return false unless sessions_available?
    return true if unlimited_sessions?

    decrement!(:sessions_remaining)
    update!(status: :expired) if sessions_exhausted?
    true
  end

  def sessions_status
    case
    when unlimited_sessions? then :unlimited
    when sessions_exhausted? then :exhausted
    when sessions_remaining <= 2 then :low
    else :available
    end
  end
end
