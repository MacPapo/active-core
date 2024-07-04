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
  end
end
