module ValidityPeriod
  extend ActiveSupport::Concern

  included do
    validates :valid_from, comparison: { less_than_or_equal_to: :valid_until },
              allow_blank: true
    validates :valid_until, comparison: { greater_than_or_equal_to: :valid_from },
              allow_blank: true

    scope :currently_valid, -> {
      where("(valid_from IS NULL OR valid_from <= ?) AND (valid_until IS NULL OR valid_until >= ?)",
            Date.current, Date.current)
    }
    scope :expired, -> { where("valid_until < ?", Date.current) }
    scope :future, -> { where("valid_from > ?", Date.current) }
  end

  def currently_valid?
    (valid_from.blank? || valid_from <= Date.current) &&
      (valid_until.blank? || valid_until >= Date.current)
  end

  def expired?
    valid_until.present? && valid_until < Date.current
  end

  def expires_soon?(days = 7)
    valid_until.present? && valid_until <= days.days.from_now
  end

  def validity_status
    return :expired if expired?
    return :expires_soon if expires_soon?
    return :valid if currently_valid?
    :future
  end
end
