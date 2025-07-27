class CreateReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :receipts do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :number, null: false
      t.integer :year, null: false
      t.date :date, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :receipts, [:number, :year], unique: true
    add_index :receipts, :discarded_at
  end
end
