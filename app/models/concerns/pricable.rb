module Pricable
  extend ActiveSupport::Concern

  # Quando includi questo concern, il modello guadagna questo metodo.
  def price_for(member)
    # Se il membro è affiliato e c'è un prezzo affiliato, usa quello.
    # Altrimenti, usa il prezzo standard.
    member.affiliated? && affiliated_price.present? ? affiliated_price : price
  end
end
