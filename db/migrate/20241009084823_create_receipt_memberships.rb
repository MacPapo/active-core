# frozen_string_literal: true

# Receipt Membership Migration
class CreateReceiptMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :receipt_memberships do |t|
      t.references :receipt, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :number, default: 0, null: false
      t.integer :year, default: 2024, null: false

      t.timestamps
    end

    add_index :receipt_memberships, %i[receipt_id id], unique: true
    add_index :receipt_memberships, %i[number year], unique: true
  end
end
