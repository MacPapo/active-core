# frozen_string_literal: true

class AddDiscardedAtToActivityPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :activity_plans, :discarded_at, :datetime
    add_index :activity_plans, :discarded_at
  end
end
