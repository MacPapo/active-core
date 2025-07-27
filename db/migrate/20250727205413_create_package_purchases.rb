class CreatePackagePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :package_purchases do |t|
      t.references :member, null: false, foreign_key: true
      t.references :package, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :billing_period_start, null: false
      t.date :billing_period_end, null: false
      t.decimal :amount_paid, precision: 8, scale: 2, null: false
      t.integer :status, default: 0, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :package_purchases, :status
    add_index :package_purchases, :discarded_at
  end
end
