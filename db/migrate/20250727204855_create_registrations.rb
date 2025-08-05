class CreateRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :registrations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :pricing_plan, null: false, foreign_key: true
      t.references :package, null: true, foreign_key: true

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :billing_period_start, null: false
      t.date :billing_period_end, null: false
      t.integer :sessions_remaining
      t.integer :status, default: 0, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :registrations, :status
    add_index :registrations, :discarded_at
  end
end
