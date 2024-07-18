class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :status, default: 0,  null: false

      t.references :user, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
