# frozen_string_literal: true

# Receipt Model
class Receipt < ApplicationRecord
  belongs_to :payment
  belongs_to :user

  validates :id, presence: true, uniqueness: true
  validates :date, :amount, :cause, presence: true

  delegate :number_to_currency, to: ActiveSupport::NumberHelper

  COMPANY = {
    name: 'ASD Querini Fit',
    email: 'asdquerinifit@gmail.com',
    phone: '+39 0413088379',
    address: 'C. de le Capucine, 6576b',
    logo: Rails.root.join('app/assets/images/asd-querini.png')
  }.freeze

  def company
    COMPANY
  end

  def self.generate_id
    date_part = Time.zone.now.strftime('%d%m%Y')
    sequence_number = Receipt.where('date(created_at) = ?', Time.zone.today).count + 1
    formatted_number = format('%04d', sequence_number)

    "#{date_part}#{formatted_number}".to_i
  end

  def amount_to_currency
    number_to_currency(amount)
  end
end
