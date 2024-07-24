class CreateLegalGuardians < ActiveRecord::Migration[7.1]
  def change
    create_table :legal_guardians do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.date :date_of_birth, null: false

      t.timestamps
    end

    add_index :legal_guardians, :email, unique: true
    add_index :legal_guardians, :name
    add_index :legal_guardians, :surname
    add_index :legal_guardians, :phone
    add_index :legal_guardians, :date_of_birth
  end
end
