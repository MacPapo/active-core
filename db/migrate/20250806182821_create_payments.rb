class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :member, null: false, foreign_key: true # CHI ha pagato
      t.references :user, null: false, foreign_key: true # QUALE staff ha registrato

      # Informazioni sulla ricevuta, ora integrate qui
      t.integer :receipt_number
      t.integer :receipt_year

      # Dati finanziari
      t.decimal :total_amount, precision: 8, scale: 2, null: false    # Importo lordo
      t.decimal :discount_amount, precision: 8, scale: 2, default: 0.0 # Totale sconti applicati
      t.decimal :final_amount, precision: 8, scale: 2, null: false     # Importo netto pagato

      # Dettagli della transazione
      t.date :date, null: false
      t.integer :payment_method, default: 0, null: false # Sarà un enum
      t.text :notes

      t.datetime :discarded_at, index: true
      t.timestamps
    end

    add_index :payments, [ :receipt_number, :receipt_year ], unique: true, where: "receipt_number IS NOT NULL"
  end
end
