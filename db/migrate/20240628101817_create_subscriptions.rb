class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :user, null: false, foreign_key: true
      t.references :activity, null: true, foreign_key: true
      t.references :plan_for_activity, null: false, foreign_key: true
      t.references :staff, null: true, foreign_key: true
      t.integer :state, default: 0, null: false
      t.boolean :payed, default: false

      t.timestamps
    end
  end
end
