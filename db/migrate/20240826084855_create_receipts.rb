# frozen_string_literal: true

# Receipts Migration
class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts, id: false do |t|
      t.integer :id, null: false, primary_key: true
      t.references :payment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.float :amount, null: false
      t.date :date, null: false
      t.string :cause

      t.timestamps
    end

    add_index :receipts, :id, unique: true
    add_index :receipts, :date
  end
end
