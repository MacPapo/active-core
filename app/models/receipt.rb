# frozen_string_literal: true

# Receipt Model
class Receipt < ApplicationRecord
  include Discard::Model

  # Associations
  belongs_to :payment
  belongs_to :user

  # Validations
  validates :number, presence: true, uniqueness: { scope: :year }
  validates :year, presence: true, numericality: {
    greater_than: 2020,
    less_than_or_equal_to: -> { Date.current.year + 1 }
  }
  validates :date, presence: true

  # Scopes
  scope :for_year, ->(year) { where(year: year) }
  scope :for_month, ->(month, year = Date.current.year) {
    where(year: year).where('CAST(strftime("%m", date) AS INTEGER) = ?', month)
  }
  scope :recent, -> { order(date: :desc, number: :desc) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }

  # Callbacks
  before_validation :set_defaults, if: :new_record?

  # Instance methods
  def receipt_number
    "#{number}/#{year}"
  end

  def formatted_date
    date.strftime("%d/%m/%Y")
  end

  def total_amount
    payment.final_amount
  end

  def formatted_total
    "€#{total_amount}"
  end

  def member_info
    return nil unless payment.payment_items.any?

    # Get member from first payment item
    first_item = payment.payment_items.first
    member = first_item.payable&.member
    return nil unless member

    {
      name: "#{member.name} #{member.surname}",
      email: member.email,
      cf: member.cf
    }
  end

  def payment_method_display
    payment.payment_method.humanize
  end

  def items_summary
    payment.payment_items.kept.map do |item|
      {
        description: item.payable_name,
        amount: item.amount,
        formatted_amount: item.formatted_amount
      }
    end
  end

  def discounts_summary
    payment.payment_discounts.map do |discount|
      {
        name: discount.discount_name,
        amount: discount.discount_amount,
        formatted_amount: discount.formatted_amount
      }
    end
  end

  def issued_by
    user.nickname
  end

  def self.next_number_for_year(year = Date.current.year)
    last_receipt = where(year: year).maximum(:number) || 0
    last_receipt + 1
  end

  def self.generate_for_payment(payment, issuing_user)
    current_year = Date.current.year

    create!(
      payment: payment,
      user: issuing_user,
      number: next_number_for_year(current_year),
      year: current_year,
      date: Date.current
    )
  end

  private

  def set_defaults
    self.date ||= Date.current
    self.year ||= date&.year || Date.current.year
    self.number ||= self.class.next_number_for_year(year)
  end
end
