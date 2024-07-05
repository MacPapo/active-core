class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.date :start
      t.date :end
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :subscription_type, null: false, foreign_key: true
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
