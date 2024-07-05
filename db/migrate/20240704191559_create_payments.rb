class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.float :amount, null: false
      t.date :date, null: false
      t.integer :method, default: 0, null: false
      t.integer :payment_type, default: 0, null: false
      t.integer :entry_type, default: 0, null: false
      t.boolean :payed, default: true, null: false
      t.text :note
      t.references :subscription, null: true, foreign_key: true
      t.references :staff, null: true, foreign_key: true

      t.timestamps
    end
  end
end
