class CreateMembershipHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :membership_histories do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :staff, null: true, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :action, default: 0, null: false

      t.timestamps
    end
  end
end
