class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :tax_code
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birth_date
      t.string :email
      t.string :phone

      t.string "address"
      t.string "city"
      t.string "province"
      t.string "zip_code"
      t.date :medical_certificate_issued_on
      t.boolean :affiliated, default: false, null: false
      t.references :legal_guardian, foreign_key: { to_table: :members }

      t.datetime :discarded_at, index: true
      t.timestamps
    end

    add_index :members, :email, unique: true, where: "discarded_at IS NULL"
  end
end
