# frozen_string_literal: true

class AddDiscardedAtToMemberships < ActiveRecord::Migration[7.1]
  def change
    add_column :memberships, :discarded_at, :datetime
    add_index :memberships, :discarded_at
  end
end
