class CreateAccessGrants < ActiveRecord::Migration[8.0]
  def change
    create_table :access_grants do |t|
      # --- Collegamenti Fondamentali ---
      t.references :member, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true, comment: "Staff che ha creato il record"

      # --- L'Oggetto Acquistato (Usa solo uno dei due) ---
      t.references :package, null: true, foreign_key: true
      t.references :pricing_plan, null: true, foreign_key: true

      # --- Cronologia e Stato ---
      t.references :renewed_from, null: true, foreign_key: { to_table: :access_grants }, comment: "Link al grant precedente (rinnovo/upgrade)"
      t.integer :status, default: 0, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      # --- Dati Aggiuntivi ---
      t.text :notes

      t.timestamps

      # --- Vincolo di Integrità per SQLite ---
      # Questo garantisce che un grant sia O per un pacchetto O per un piano, MAI entrambi o nessuno.
      t.check_constraint "(package_id IS NOT NULL AND pricing_plan_id IS NULL) OR (package_id IS NULL AND pricing_plan_id IS NOT NULL)",
                         name: 'grant_has_one_source'
    end

    # --- Indici per Performance Ottimali ---
    # Per trovare rapidamente gli abbonamenti in scadenza
    add_index :access_grants, [ :status, :end_date ]

    # Per trovare rapidamente gli abbonamenti legati a un pacchetto o piano specifico
    add_index :access_grants, [ :package_id, :pricing_plan_id ]
  end
end
