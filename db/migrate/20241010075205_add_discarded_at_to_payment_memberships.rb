# frozen_string_literal: true

class AddDiscardedAtToPaymentMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_memberships, :discarded_at, :datetime
    add_index :payment_memberships, :discarded_at
  end
end
