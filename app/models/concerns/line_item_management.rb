module LineItemManagement
  extend ActiveSupport::Concern

  included do
    validates :amount, comparison: { greater_than_or_equal_to: 0 }, presence: true
    validates :description, length: { maximum: 500 }, allow_blank: true
    validates :payable_type, :payable_id, presence: true

    scope :by_amount_range, ->(min, max) { where(amount: min..max) }
    scope :expensive_items, -> { where(amount: 50..) }
    scope :by_payable_type, ->(type) { where(payable_type: type) if type.present? }
  end

  def expensive_item?
    amount >= 50
  end

  def item_category
    payable_type.underscore.humanize
  end

  def display_description
    description.presence || default_description
  end

  def contributes_significantly?
    return false unless payment&.total_amount&.positive?
    (amount / payment.total_amount) > 0.3
  end

  private

  def default_description
    return "Unknown item" unless payable

    case payable
    when Membership
      "Membership: #{payable.pricing_plan.display_name}"
    when Registration
      "Course: #{payable.product.name}"
    when PackagePurchase
      "Package: #{payable.package.name}"
    else
      payable_type.humanize
    end
  end
end
