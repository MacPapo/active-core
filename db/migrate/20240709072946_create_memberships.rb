class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.date :date, null: false
      t.boolean :active, default: false,  null: false
      t.float :cost, null: false, default: 35.0
      t.boolean :payed, default: false

      t.references :user, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: true

      t.timestamps
    end
  end
end
