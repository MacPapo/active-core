class CreateSubscriptionTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_types do |t|
      t.text :desc
      t.integer :duration
      t.float :cost

      t.timestamps
    end
    add_index :subscription_types, :desc, unique: true
  end
end
