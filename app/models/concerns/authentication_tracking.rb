module AuthenticationTracking
  extend ActiveSupport::Concern

  included do
    validates :sign_in_count, comparison: { greater_than_or_equal_to: 0 }

    scope :recently_active, -> { where(current_sign_in_at: 1.week.ago..) }
    scope :inactive_users, -> { where(current_sign_in_at: ..1.month.ago) }
    scope :never_signed_in, -> { where(sign_in_count: 0) }
    scope :frequent_users, -> { where(sign_in_count: 10..) }
  end

  def recently_active?
    current_sign_in_at&.> 1.week.ago
  end

  def never_signed_in?
    sign_in_count.zero?
  end

  def last_sign_in_days_ago
    return unless last_sign_in_at
    (Time.current - last_sign_in_at).to_i / 1.day
  end

  def frequent_user?
    sign_in_count >= 10
  end
end
