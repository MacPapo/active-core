# frozen_string_literal: true

# Receipt Migration
class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts do |t|
      t.references :payment, null: false, foreign_key: true
      t.date :date, null: false
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
