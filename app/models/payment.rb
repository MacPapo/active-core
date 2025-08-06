class Payment < ApplicationRecord
  include Discard::Model

  # --- ASSOCIAZIONI ---
  belongs_to :member
  belongs_to :user # Staff

  # Un pagamento è composto da una o più "righe d'ordine"
  has_many :payment_items, dependent: :destroy
  # Un pagamento può avere uno o più sconti applicati
  has_many :payment_discounts, dependent: :destroy
  has_many :discounts, through: :payment_discounts

  accepts_nested_attributes_for :payment_items, allow_destroy: true
  accepts_nested_attributes_for :payment_discounts, allow_destroy: true

  # --- ENUM ---
  enum payment_method: { cash: 0, card: 1, bank_transfer: 2, other: 3 }

  # --- LOGICA ---
  before_validation :calculate_totals

  private

  # Questo metodo è la chiave: calcola e ricalcola i totali
  # ogni volta che il pagamento viene salvato, garantendo coerenza.
  def calculate_totals
    # Il totale lordo è la somma degli importi delle singole righe d'ordine
    self.total_amount = payment_items.sum(&:amount)

    # Il totale degli sconti è la somma degli sconti applicati
    self.discount_amount = payment_discounts.sum(&:discount_amount)

    # Il finale è semplicemente la differenza
    self.final_amount = total_amount - discount_amount
  end
end
