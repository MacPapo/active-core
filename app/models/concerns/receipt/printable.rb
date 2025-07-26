module Receipt::Printable
  extend ActiveSupport::Concern

  def to_pdf
    Receipts::Receipt.new(
      title: "RICEVUTA",
      details: receipt_details,
      company: company_details,
      recipient: recipient_details,
      line_items: line_items,
      footer: "Grazie per averci scelto. Contattaci per qualsiasi domanda."
    ).render
  end

  private

  # Costruisce i dettagli dell'azienda.
  # CONSIGLIO: Sposta questi dati in Rails credentials o in un file di configurazione.
  def company_details
    {
      name: "NOME DELLA TUA PALESTRA ASD",
      address: "Via Roma, 123\n00100 Roma (RM)",
      email: "info@tua-palestra.it",
      phone: "06 12345678",
      logo: Rails.root.join("app/assets/images/asd-querini.png")
    }
  end

  # Costruisce i dettagli specifici della ricevuta (numero, data, etc.).
  def receipt_details
    [
      [ "Numero Ricevuta", "#{number}/#{year}" ],
      [ "Data Pagamento", I18n.l(payment.date) ],
      [ "Metodo di Pagamento", payment.payment_method.humanize ],
      [ "Operatore", payment.user.nickname ]
    ]
  end

  # Trova il membro destinatario della ricevuta.
  def recipient_member
    payment.payment_items.first&.payable&.member
  end

  # Costruisce i dati del destinatario.
  def recipient_details
    member = recipient_member
    if member.present?
      [
        "<b>Intestatario Ricevuta:</b>",
        "#{member.name} #{member.surname}",
        ("CF: #{member.cf}" if member.cf.present?),
        member.email
      ].compact
    else
      [ "Destinatario non specificato" ]
    end
  end

  # Costruisce le righe della tabella degli articoli, incluso il riepilogo.
  def line_items
    items = [
      [ "<b>Descrizione</b>", "<b>Importo</b>" ]
    ]

    payment.payment_items.each do |item|
      description = item.description.presence || item.payable&.product&.name || item.payable&.package&.name || "Articolo"
      items << [ description, format_currency(item.amount) ]
    end

    items.concat(summary_line_items)
  end

  # Costruisce le righe di riepilogo (subtotale, sconti, totale).
  def summary_line_items
    summary = []
    summary << [ nil, "Subtotale", format_currency(payment.total_amount) ]

    if payment.discount_amount.to_f > 0
      summary << [ nil, "Sconto Applicato", format_currency(-payment.discount_amount) ]
    end

    summary << [ nil, "<b>Totale Pagato</b>", "<b>#{format_currency(payment.final_amount)}</b>" ]

    summary
  end

  # Helper per formattare i valori decimali come valuta.
  def format_currency(amount)
    "€ #{'%.2f' % amount}"
  end
end
