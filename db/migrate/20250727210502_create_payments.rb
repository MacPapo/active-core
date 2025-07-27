class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true

      t.decimal :total_amount, precision: 8, scale: 2, null: false
      t.decimal :discount_amount, precision: 8, scale: 2, default: 0, null: false
      t.decimal :final_amount, precision: 8, scale: 2, null: false
      t.date :date, null: false
      t.integer :payment_method, default: 0, null: false
      t.boolean :income, default: true, null: false
      t.text :notes

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :payments, :date
    add_index :payments, :payment_method
    add_index :payments, :discarded_at
  end
end
