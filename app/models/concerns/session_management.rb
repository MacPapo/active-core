module SessionManagement
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

    update!(sessions_remaining: sessions_remaining - 1)
    update!(status: :expired) if sessions_exhausted?
    true
  end

  def sessions_status
    return :unlimited if unlimited_sessions?
    return :exhausted if sessions_exhausted?
    return :low if sessions_remaining <= 2
    :available
  end
end
