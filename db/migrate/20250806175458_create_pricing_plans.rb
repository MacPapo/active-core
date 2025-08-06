class CreatePricingPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :pricing_plans do |t|
      t.references :product, null: false, foreign_key: true

      # Il nome che vedrà l'operatore (es. "Abbonamento Mensile")
      t.string :name, null: false

      # Prezzo
      t.decimal :price, precision: 8, scale: 2, null: false
      t.decimal :affiliated_price, precision: 8, scale: 2

      # Durata (più chiara)
      t.integer :duration_interval, null: false # Es. 1, 3, 12
      t.integer :duration_unit, null: false     # Es. 'month', 'year'

      # Periodo di validità del piano stesso (non dell'abbonamento venduto)
      t.date :valid_from
      t.date :valid_until

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :pricing_plans, [ :product_id, :name ], unique: true, where: "discarded_at IS NULL"
    add_index :pricing_plans, :discarded_at
  end
end
