# frozen_string_literal: true

class AddDiscardedAtToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :discarded_at, :datetime
    add_index :activities, :discarded_at
  end
end
