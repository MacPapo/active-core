# frozen_string_literal: true

class AddDiscardedAtToReceiptSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :receipt_subscriptions, :discarded_at, :datetime
    add_index :receipt_subscriptions, :discarded_at
  end
end
