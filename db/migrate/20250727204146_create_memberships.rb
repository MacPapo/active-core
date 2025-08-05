class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.references :pricing_plan, null: false, foreign_key: true
      t.references :renewed_from, null: true, foreign_key: { to_table: :memberships }

      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :billing_period_start, null: false
      t.date :billing_period_end, null: false
      t.integer :status, default: 0, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :memberships, :status
    add_index :memberships, [ :start_date, :end_date ]
    add_index :memberships, :discarded_at
  end
end
