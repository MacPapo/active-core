# frozen_string_literal: true

class AddDiscardedAtToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :discarded_at, :datetime
    add_index :payments, :discarded_at
  end
end
