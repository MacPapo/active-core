class CreatePaymentItems < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_items do |t|
      t.references :payment, null: false, foreign_key: true

      # Polymorphic
      t.string :payable_type, null: false
      t.integer :payable_id, null: false

      t.decimal :amount, precision: 8, scale: 2, null: false
      t.text :description

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :payment_items, [:payable_type, :payable_id]
    add_index :payment_items, :discarded_at
  end
end
