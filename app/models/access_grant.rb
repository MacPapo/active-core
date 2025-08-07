# frozen_string_literal: true

# Access Grant Model
class AccessGrant < ApplicationRecord
  # --- Associazioni ---
  belongs_to :member
  belongs_to :user, optional: true # Staff che ha creato/modificato

  belongs_to :package, optional: true
  belongs_to :pricing_plan, optional: true

  # Per la cronologia dei rinnovi
  belongs_to :renewed_from, class_name: "AccessGrant", optional: true
  has_one :renewal, class_name: "AccessGrant", foreign_key: "renewed_from_id"

  # Sfruttiamo la tua tabella 'payments' esistente!
  has_many :payments, as: :payable, dependent: :destroy
  accepts_nested_attributes_for :payments

  # --- Validazioni ---
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :exactly_one_purchasable_present

  # ------------------------------------------------------------------
  # ENUM per lo STATO
  # ------------------------------------------------------------------
  enum :status, {
         pending: 0,   # Creato ma non ancora attivo (es. partenza futura)
         active: 1,    # Attualmente valido
         expired: 2,   # Scaduto
         cancelled: 3, # Annullato manualmente
         upgraded: 4   # Interrotto perché sostituito da un upgrade
       }

  # ------------------------------------------------------------------
  # VALIDAZIONI
  # ------------------------------------------------------------------
  validates :start_date, :end_date, :status, presence: true
  validate :end_date_after_start_date
  validate :exactly_one_purchasable_present

  # ------------------------------------------------------------------
  # SCOPES (Scorciatoie per le query)
  # ------------------------------------------------------------------
  scope :active_on, ->(date) { active.where("start_date <= ? AND end_date >= ?", date, date) }

  # ------------------------------------------------------------------
  # METODI DI UTILITÀ
  # ------------------------------------------------------------------

  # Restituisce l'oggetto acquistato (Package o PricingPlan), che è l'origine di questo grant.
  def source
    package || pricing_plan
  end

  # Restituisce il nome dell'abbonamento.
  def name
    source.name
  end

  # Restituisce il nome completo, es: "Mario Rossi - OPEN Mensile"
  def full_description
    "#{member.full_name} - #{source.name}"
  end

  # Calcola il prezzo per il membro specifico.
  def price
    source.price_for(member)
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, "deve essere successiva alla data di inizio") if end_date < start_date
  end

  def exactly_one_purchasable_present
    # Il CHECK constraint del DB è la vera guardia, questa è una validazione a livello Rails.
    unless package.present? ^ pricing_plan.present?
      errors.add(:base, "È necessario specificare un Pacchetto o un Piano Tariffario, ma non entrambi.")
    end
  end
end
