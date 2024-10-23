# frozen_string_literal: true

# Payment Membership Migration
class CreatePaymentMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_memberships do |t|
      t.references :payment, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :payment_memberships, %i[payment_id id], unique: true
  end
end
