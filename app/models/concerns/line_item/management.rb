module LineItem::Management
  extend ActiveSupport::Concern

  included do
    validates :amount, comparison: { greater_than_or_equal_to: 0, presence: true }
    validates :description, length: { maximum: 500 }, allow_blank: true
    validates :payable_type, :payable_id, presence: true

    scope :by_amount_range, ->(min, max) { where(amount: min..max) }
    scope :expensive_items, -> { where("amount >= 50") }
    scope :by_payable_type, ->(type) { where(payable_type: type) if type.present? }
  end

  def expensive_item?
    amount >= 50
  end

  # TODO localize
  def item_category
    I18n.t("line_items.category.#{payable_type.underscore}")
  end

  def display_description
    description.presence || default_description
  end

  def contributes_significantly?
    return false unless payment&.total_amount&.positive?
    (amount.to_f / payment.total_amount) > 0.3
  end

  private

  # TODO localize
  def default_description
    return I18n.t("line_items.description.unknown_item") unless payable

    case payable
    when Membership
      I18n.t("line_items.description.membership", name: payable.pricing_plan.display_name)
    when Registration
      I18n.t("line_items.description.registration", name: payable.product.name)
    when PackagePurchase
      I18n.t("line_items.description.package", name: payable.package.name)
    else
      I18n.t("line_items.description.default", type: payable_type.humanize)
    end
  end
end
