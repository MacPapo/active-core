# frozen_string_literal: true

# Payment Migration
class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.date :date, null: false
      t.integer :method, default: 0, null: false
      t.boolean :income, default: true, null: false
      t.text :note
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
