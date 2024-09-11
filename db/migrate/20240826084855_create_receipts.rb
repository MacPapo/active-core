# frozen_string_literal: true

# Receipts Migration
class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts do |t|
      t.integer :sub_num, null: false
      t.integer :mem_num, null: false
      t.references :payment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.float :amount, null: false
      t.date :date, null: false
      t.string :cause

      t.timestamps
    end

    add_index :receipts, [:sub_num, :date]
    add_index :receipts, [:mem_num, :date]
    add_index :receipts, :date
  end
end
