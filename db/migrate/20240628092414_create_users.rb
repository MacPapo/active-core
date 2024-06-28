class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :surname, null: false
      t.string :email
      t.string :phone
      t.date :date_of_birth, null: false
      t.date :med_cert_exp_date
      t.references :legal_guardian, null: true, foreign_key: true

      t.timestamps
    end
  end
end
