class CreatePaymentDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_discounts do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :discount, null: false, foreign_key: true
      t.decimal :discount_amount, precision: 8, scale: 2, null: false
      t.text :notes

      t.timestamps
    end

    add_index :payment_discounts, [ :payment_id, :discount_id ], unique: true
  end
end
