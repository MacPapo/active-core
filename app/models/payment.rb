class Payment < ApplicationRecord
  belongs_to :subscription, optional: true
  belongs_to :staff

  validates :amount, :date, :method, :payment_type, :entry_type, :state, presence: true
  validates :method, inclusion: { in: %w[pos contanti bonifico indefinito] }
  validates :payment_type, inclusion: { in: %w[abbonamento quota altro] }
  validates :entry_type, inclusion: { in: %w[entrata uscita] }
  validates :state, inclusion: { in: %w[pagato non_pagato] }
end
