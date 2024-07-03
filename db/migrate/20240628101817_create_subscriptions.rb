class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.date :start
      t.date :end
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :subscription_type, null: false, foreign_key: true
      t.string :state

      t.timestamps
    end

    add_check_constraint :subscriptions, "state IN ('attivo', 'scaduto', 'cancellato')", name: "state_check"
  end
end
