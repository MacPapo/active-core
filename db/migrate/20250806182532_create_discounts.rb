class CreateDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :discounts do |t|
      t.string :name, null: false
      t.text :description
      t.integer :discount_type, default: 0, null: false # Sarà un enum: 'percentage' o 'fixed'
      t.decimal :value, precision: 8, scale: 2, null: false # Il valore dello sconto (es. 10 per 10% o 5.00 per 5€)

      t.date :valid_from
      t.date :valid_until

      t.datetime :discarded_at, index: true
      t.timestamps
    end

    add_index :discounts, :name, unique: true, where: "discarded_at IS NULL"
  end
end
