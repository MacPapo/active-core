class Payment < ApplicationRecord
  belongs_to :subscription, optional: true
  belongs_to :staff

  enum payment_method: [:pos, :contanti, :bonifico, :indefinito]
  enum payment_type: [:abbonamento, :quota, :altro]
  enum entry_type: [:entrata, :uscita]

  validates :amount,
            :date,
            :payment_method,
            :payment_type,
            :entry_type,
            :payed,
            :staff,
            presence: true
end
