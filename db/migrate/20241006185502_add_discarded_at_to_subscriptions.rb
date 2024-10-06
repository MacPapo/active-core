# frozen_string_literal: true

class AddDiscardedAtToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :discarded_at, :datetime
    add_index :subscriptions, :discarded_at
  end
end
