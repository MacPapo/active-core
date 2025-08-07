class PricingPlan < ApplicationRecord
  include Discard::Model
  include Pricable
  include HasValidityPeriod

  belongs_to :product

  # Un piano tariffario può essere venduto molte volte tramite gli AccessGrant
  # Se eliminiamo un piano dal listino, non eliminiamo le vendite già fatte!
  has_many :access_grants, dependent: :restrict_with_error

  # ------------------------------------------------------------------
  # ENUM
  # ------------------------------------------------------------------

  # Definiamo le unità di durata possibili in modo pulito e leggibile
  enum :duration_unit, {
         day: 0,
         week: 1,
         month: 2,
         year: 3
       }

  # ------------------------------------------------------------------
  # VALIDAZIONI
  # ------------------------------------------------------------------

  validates :name, :duration_interval, :duration_unit, :price, presence: true
  validates :name, uniqueness: { scope: :product_id, conditions: -> { kept } }
  validates :price, :affiliated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration_interval, numericality: { only_integer: true, greater_than: 0 }

  # ------------------------------------------------------------------
  # METODI DI UTILITÀ
  # ------------------------------------------------------------------

  # Il nome completo che puoi mostrare nelle interfacce, es. "Corso di Karate - Mensile"
  def full_name
    "#{product.name} - #{name}"
  end

  # Metodo FONDAMENTALE: calcola la data di scadenza di un abbonamento
  # basandosi su questo piano tariffario.
  def calculate_end_date(start_date)
    return nil unless start_date.is_a?(Date)
    # La magia di ActiveSupport: 1.month, 3.years, etc.
    start_date + duration_interval.send(duration_unit)
  end
end
