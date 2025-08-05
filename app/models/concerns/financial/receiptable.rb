module Financial::Receiptable
  extend ActiveSupport::Concern

  included do
    # Ogni pagamento ha una sola ricevuta. La dipendenza `destroy` garantisce
    # che se il pagamento viene eliminato, anche la sua ricevuta lo sarà.
    has_one :receipt, class_name: "Receipt", dependent: :destroy
  end

  # Genera una ricevuta per questo pagamento.
  # La logica è incapsulata qui per essere riutilizzabile e atomica.
  # Lancia un'eccezione in caso di fallimento per forzare il rollback della transazione chiamante.
  #
  # @return [Receipt] L'oggetto Receipt creato.
  #
  def generate_receipt!
    # Se il pagamento ha già una ricevuta, non ne crea un'altra.
    return receipt if receipt.present?

    # Crea la ricevuta usando il metodo `create!` che solleva un'eccezione
    # in caso di fallimento, annullando la transazione esterna (quella in `register_payment`).
    create_receipt!(
      date: self.date,
      year: self.date.year,
      progressive_number: _next_receipt_number(self.date.year)
    )
  end

  private

  # Calcola il prossimo numero progressivo per le ricevute dell'anno specificato.
  # Questo metodo è cruciale per evitare numeri duplicati (race conditions).
  #
  # @param year [Integer] L'anno per cui calcolare il numero.
  # @return [Integer] Il prossimo numero di ricevuta disponibile.
  #
  def _next_receipt_number(year)
    # ActiveRecord `lock` garantisce che questa operazione sia sicura in ambienti concorrenti.
    # Viene acquisito un lock a livello di tabella (o di righe, a seconda del DB)
    # che impedisce ad altri processi di leggere l'ultimo numero fino a che la transazione non è completa.
    Receipt.transaction do
      # Trova l'ultima ricevuta per l'anno dato, applicando un lock pessimistico.
      last_receipt = Receipt.where(year: year).lock(true).order(progressive_number: :desc).first

      # Se c'è un'ultima ricevuta, il nuovo numero è il suo progressivo + 1.
      # Altrimenti, questa è la prima ricevuta dell'anno e il numero è 1.
      last_receipt ? last_receipt.progressive_number + 1 : 1
    end
  end
end
