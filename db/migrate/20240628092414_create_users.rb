# frozen_string_literal: true

# User Migration
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string     :cf
      t.string     :name, null: false
      t.string     :surname, null: false
      t.string     :email
      t.string     :phone
      t.date       :birth_day
      t.date       :med_cert_issue_date
      t.boolean    :affiliated, default: false, null: false
      t.references :legal_guardian, null: true, foreign_key: true

      t.timestamps
    end
  end
end
