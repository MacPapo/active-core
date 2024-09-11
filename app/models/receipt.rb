# frozen_string_literal: true

# Receipt Model
class Receipt < ApplicationRecord
  belongs_to :payment
  belongs_to :user

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

  def self.generate_number(type)
    last = Receipt.last

    case type
    when 'Membership'
      [last.blank? ? 0 : last.sub_num, last.blank? ? 1 : last.mem_num + 1]
    when 'Subscription'
      [last.blank? ? 1 : last.sub_num + 1, last.blank? ? 0 : last.mem_num]
    else
      p 'else'
    end
  end

  def amount_to_currency
    number_to_currency(amount)
  end
end
