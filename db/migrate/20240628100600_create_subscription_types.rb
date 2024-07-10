class CreateSubscriptionTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_types do |t|
      t.integer :plan, default: 0, null: false
      t.text :desc
      t.integer :category, default: 0, null: false

      t.timestamps
    end
  end
end
