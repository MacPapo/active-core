module Financial::Payable
  extend ActiveSupport::Concern

  def register_payment(user:, payment_method:, date: Date.current, amount: nil, discounts: [], notes: nil)
    ApplicationRecord.transaction do
      base_amount = amount || self.price
      total_discount = discounts.sum(&:value) # Assumiamo che `value` sia l'importo fisso dello sconto.

      payment = Payment.new(
        user:,
        total_amount: base_amount,
        discount_amount: total_discount,
        final_amount: base_amount - total_discount,
        date:,
        payment_method:,
        income: true,
        notes:
      )

      payment.payment_items.build(
        payable: self,
        amount: base_amount,
        description: self.try(:name) || self.class.model_name.human
      )

      discounts.each { |discount| payment.payment_discounts.build(discount:, discount_amount: discount.value) }

      payment.save!
      payment.generate_receipt!

      return payment
    end
  rescue ActiveRecord::RecordInvalid => e
    # Se una qualsiasi delle validazioni (su Payment, PaymentItem, etc.) fallisce,
    # la transazione viene annullata automaticamente.
    # Aggiungiamo l'errore all'oggetto corrente per poterlo mostrare nell'interfaccia utente.
    errors.add(:base, "Errore nella registrazione del pagamento: #{e.message}")
    nil # Restituisce nil per indicare il fallimento.
  end
end
