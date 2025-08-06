class PaymentItem < ApplicationRecord
  # --- ASSOCIAZIONI ---
  belongs_to :payment
  # Il collegamento polimorfico è ora opzionale.
  belongs_to :payable, polymorphic: true, optional: true

  # --- VALIDAZIONI ---
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # --- LOGICA ---
  # Se l'item è collegato a un AccessGrant, prendiamo la sua descrizione di default.
  # Altrimenti, usiamo la descrizione manuale.
  before_validation :set_description_from_payable, on: :create

  private

  def set_description_from_payable
    # Se la descrizione è già stata impostata manualmente, non fare nulla.
    return if description.present?

    # Se l'item è collegato a un "payable", usiamo la sua descrizione.
    if payable.present? && payable.respond_to?(:name)
      self.description = payable.name
    end
  end
end
