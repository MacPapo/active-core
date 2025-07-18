# frozen_string_literal: true

# Subscriptions Migration
class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.date       :start_date, null: false
      t.date       :end_date, null: false
      t.integer    :status, default: 0, null: false

      t.references :user, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.references :activity_plan, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true

      t.references :open_subscription, null: true, foreign_key: { to_table: :subscriptions }

      t.timestamps
    end
  end
end
