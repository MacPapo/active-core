class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :cf
      t.string :name, null: false
      t.string :surname, null: false
      t.string :email
      t.string :phone
      t.date :birth_day
      t.date :med_cert_issue_date
      t.boolean :affiliated, default: false, null: false
      t.references :legal_guardian, null: true, foreign_key: true

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :members, :email, unique: true, where: "email IS NOT NULL"
    add_index :members, :discarded_at
  end
end
