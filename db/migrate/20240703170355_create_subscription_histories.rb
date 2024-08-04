class CreateSubscriptionHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_histories do |t|
      t.date       :renewal_date
      t.date       :old_end_date
      t.date       :new_end_date
      t.integer    :action       , default: 0, null: false

      t.references :subscription , null: false, foreign_key: true
      t.references :staff        , null: true, foreign_key: true

      t.timestamps
    end
  end
end
