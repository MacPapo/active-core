# frozen_string_literal: true

# Receipt Model
class Receipt < ApplicationRecord
  include Discard::Model

  belongs_to :payment
  belongs_to :user

  validates :number, :year, :date, presence: true
  validates :number, uniqueness: { scope: :year }
  validates :number, numericality: { greater_than: 0 }
  validates :year, numericality: {
              greater_than: 2020,
              less_than_or_equal_to: -> { Date.current.year + 1 }
            }

  scope :for_year, ->(year) { where(year: year) }
  scope :for_payment, ->(payment) { where(payment: payment) }
  scope :by_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }
  scope :this_month, -> { where(date: Date.current.beginning_of_month..) }

  before_validation :set_defaults, on: :create, if: :should_auto_assign?

  def receipt_number
    "#{number}/#{year}"
  end

  def description
    "Receipt #{receipt_number} - €#{payment.final_amount}"
  end

  def amount
    payment.final_amount
  end

  def payment_method
    payment.payment_method
  end

  def self.next_number_for_year(year = Date.current.year)
    where(year: year).maximum(:number).to_i + 1
  end

  private

  def should_auto_assign?
    number.blank? || year.blank? || date.blank?
  end

  def set_defaults
    self.year ||= Date.current.year
    self.date ||= Date.current
    self.number ||= self.class.next_number_for_year(year)
  end
end
