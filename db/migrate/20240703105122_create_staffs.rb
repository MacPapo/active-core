class CreateStaffs < ActiveRecord::Migration[7.1]
  def change
    create_table :staffs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :card_expiry_date
      t.string :password, null: false
      t.string :role, null: false

      t.timestamps
    end
  end
end
