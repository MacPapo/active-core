# frozen_string_literal: true

# Activity Plans Migration
class CreateActivityPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_plans do |t|
      t.integer    :plan, default: 0, null: false
      t.decimal    :cost, precision: 8, scale: 2, null: false
      t.decimal    :affiliated_cost, precision: 8, scale: 2, null: true
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
