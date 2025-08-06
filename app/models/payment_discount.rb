class PaymentDiscount < ApplicationRecord
  # --- ASSOCIAZIONI ---
  belongs_to :payment
  belongs_to :discount

  # --- VALIDAZIONI ---
  # Dobbiamo assicurarci che l'importo dello sconto sia sempre registrato.
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }
end
