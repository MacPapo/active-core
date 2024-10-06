# frozen_string_literal: true

class AddDiscardedAtToReceipts < ActiveRecord::Migration[7.1]
  def change
    add_column :receipts, :discarded_at, :datetime
    add_index :receipts, :discarded_at
  end
end
