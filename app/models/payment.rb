class Payment < ApplicationRecord
  belongs_to :subscription, optional: true
  belongs_to :staff

  enum method: [:pos, :contanti, :bonifico, :indefinito]
  after_initialize :set_default_method, :if => :new_record?
  def set_default_method
    self.method ||= :contanti
  end

  enum payment_type: [:abbonamento, :quota, :altro]
  after_initialize :set_default_payment_type, :if => :new_record?
  def set_default_payment_type
    self.payment_type ||= :abbonamento
  end

  enum entry_type: [:entrata, :uscita]
  after_initialize :set_default_entry_type, :if => :new_record?
  def set_default_entry_type
    self.entry_type ||= :entrata
  end

  validates :amount, :date, :method, :payment_type, :entry_type, :payed, presence: true
end
