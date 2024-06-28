class CreateLegalGuardians < ActiveRecord::Migration[7.1]
  def change
    create_table :legal_guardians do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :phone
      t.date :date_of_birth

      t.timestamps
    end
  end
end
