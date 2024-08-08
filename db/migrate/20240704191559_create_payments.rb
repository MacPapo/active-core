class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.float      :amount         , null: false
      t.date       :date           , null: false
      t.integer    :payment_method , default: 0, null: false
      t.integer    :entry_type     , default: 0, null: false
      t.boolean    :payed          , default: true, null: false
      t.text       :note

      t.references :staff          , null: true, foreign_key: true
      t.references :payable        , polymorphic: true

      t.timestamps
    end

    add_index :payments, :date
    add_index :payments, :payment_method
    add_index :payments, :entry_type
    add_index :payments, :payed

    add_index :payments, :created_at
    add_index :payments, :updated_at
  end
end
