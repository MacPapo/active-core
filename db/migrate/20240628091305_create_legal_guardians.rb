# frozen_string_literal: true

# Legal Guardian Migration
class CreateLegalGuardians < ActiveRecord::Migration[7.1]
  def change
    create_table :legal_guardians do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.date   :birth_day, null: false

      t.timestamps
    end

    add_index :legal_guardians, :email, unique: true
  end
end
