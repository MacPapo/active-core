module FinancialTransaction
  extend ActiveSupport::Concern

  included do
    enum :payment_method, { cash: 0, card: 1, bank_transfer: 2, check: 3, voucher: 4 },
         validate: true

    validates :total_amount, :final_amount,
              comparison: { greater_than_or_equal_to: 0 }, presence: true
    validates :discount_amount,
              comparison: { greater_than_or_equal_to: 0 }, presence: true
    validates :date, presence: true,
              comparison: { less_than_or_equal_to: -> { Date.current } }

    scope :by_amount_range, ->(min, max) { where(final_amount: min..max) }
    scope :by_date_range, ->(from, to) { where(date: from..to) }
    scope :by_method, ->(method) { where(payment_method: method) if method.present? }
    scope :recent, -> { where(date: 1.month.ago..) }
    scope :today, -> { where(date: Date.current) }
    scope :this_month, -> { where(date: Date.current.beginning_of_month..) }
  end

  def has_discount?
    discount_amount.positive?
  end

  def discount_percentage
    return 0 if total_amount.zero?
    (discount_amount / total_amount * 100).round(2)
  end

  def net_amount
    final_amount
  end

  def transaction_type
    income? ? :income : :expense
  end

  def payment_method_display
    payment_method.humanize
  end
end
