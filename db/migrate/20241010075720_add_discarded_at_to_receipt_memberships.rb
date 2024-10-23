# frozen_string_literal: true

class AddDiscardedAtToReceiptMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :receipt_memberships, :discarded_at, :datetime
    add_index :receipt_memberships, :discarded_at
  end
end
