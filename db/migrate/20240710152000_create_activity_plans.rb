class CreateActivityPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_plans do |t|
      t.integer :plan, default: 0, null: false
      t.float :cost, null: false
      t.float :affiliated_cost, null: true
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
