# frozen_string_literal: true

class AddDiscardedAtToPaymentSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_subscriptions, :discarded_at, :datetime
    add_index :payment_subscriptions, :discarded_at
  end
end
