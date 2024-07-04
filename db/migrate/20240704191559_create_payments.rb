class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.float :amount, null: false
      t.date :date, null: false
      t.string :method, null: false
      t.string :payment_type, null: false
      t.string :entry_type, null: false
      t.string :state, null: false
      t.text :note
      t.references :subscription, null: true, foreign_key: true
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :payments, "method IN ('pos', 'contanti', 'bonifico')", name: "payments_method_check"
    add_check_constraint :payments, "payment_type IN ('abbonamento', 'quota', 'altro')", name: "payments_type_check"
    add_check_constraint :payments, "entry_type IN ('entrata', 'uscita')", name: "payments_entry_check"
    add_check_constraint :payments, "state IN ('pagato', 'non_pagato')", name: "payments_state_check"
  end
end
