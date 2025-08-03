module Discount::Mechanics
  extend ActiveSupport::Concern

  included do
    enum :discount_type, { percentage: 0, fixed_amount: 1 }, validate: true
    enum :applicable_to, { all_services: 0, memberships: 1, courses: 2, packages: 3 }, validate: true

    validates :name, presence: true, length: { in: 1..100 },
              uniqueness: { case_sensitive: false, conditions: -> { where(discarded_at: nil) } }
    validates :value, comparison: { greater_than: 0 }, presence: true
    validates :max_amount, comparison: { greater_than: 0 }, allow_blank: true

    normalizes :name, with: -> { _1&.titleize&.strip }

    scope :by_type, ->(type) { where(discount_type: type) if type.present? }
    scope :by_applicable_to, ->(target) { where(applicable_to: target) if target.present? }
    scope :stackable_discounts, -> { where(stackable: true) }
    scope :non_stackable, -> { where(stackable: false) }
  end

  def percentage_discount?
    discount_type == "percentage"
  end

  def fixed_amount_discount?
    discount_type == "fixed_amount"
  end

  def calculate_discount_for(amount)
    return 0 if amount.nil? || amount.zero?

    discount_amount =
      if percentage_discount?
        amount * (value / 100.0)
      else
        value
      end

    # Apply max_amount cap if set
    discount_amount = [ discount_amount, max_amount ].min if max_amount.present?

    # Can't discount more than the original amount
    [ discount_amount, amount ].min
  end

  def discount_description
    case discount_type
    when "percentage"
      suffix = max_amount ? " (max €#{max_amount})" : ""
      "#{value}% off#{suffix}"
    when "fixed_amount"
      "€#{value} off"
    else
      "Unknown discount"
    end
  end
end
