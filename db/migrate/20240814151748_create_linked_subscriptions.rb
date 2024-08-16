# frozen_string_literal: true

class CreateLinkedSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :linked_subscriptions do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :open_subscription, null: false, foreign_key: { to_table: :subscriptions }

      t.timestamps
    end
  end
end
