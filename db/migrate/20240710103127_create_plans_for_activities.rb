class CreatePlansForActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :plans_for_activities do |t|
      t.belongs_to :activity, null: false
      t.belongs_to :subscription_type, null: false
      t.integer :duration, null: false
      t.float :cost, null: false
      t.float :affilated_cost, null: true

      t.timestamps
    end
  end
end
