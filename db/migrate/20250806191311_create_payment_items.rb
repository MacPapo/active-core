class CreatePaymentItems < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_items do |t|
      t.references :payment, null: false, foreign_key: true

      t.references :payable, polymorphic: true, null: true, index: true
      t.string :description, null: false

      t.decimal :amount, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
