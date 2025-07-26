class CreateDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :discounts do |t|
      t.string :name, null: false
      t.integer :discount_type, default: 0, null: false
      t.decimal :value, precision: 8, scale: 2, null: false
      t.decimal :max_amount, precision: 8, scale: 2
      t.date :valid_from
      t.date :valid_until
      t.boolean :stackable, default: true, null: false
      t.integer :applicable_to, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.integer :payment_discounts_count, default: 0, null: false
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :discounts, :name, unique: true, where: "discarded_at IS NULL"
    add_index :discounts, :applicable_to
    add_index :discounts, :discarded_at
  end
end
