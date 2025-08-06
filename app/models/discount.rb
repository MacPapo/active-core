class Discount < ApplicationRecord
  include Discard::Model

  enum discount_type: { percentage: 0, fixed: 1 }

  validates :name, :discount_type, :value, presence: true
  validates :name, uniqueness: { conditions: -> { kept } }
  validates :value, numericality: { greater_than: 0 }

  # Calcola l'importo dello sconto su un totale
  def apply(total)
    return 0 if total <= 0
    if percentage?
      (total * value / 100.0).round(2)
    else # fixed?
      [ total, value ].min # Non puoi scontare più del totale
    end
  end
end
