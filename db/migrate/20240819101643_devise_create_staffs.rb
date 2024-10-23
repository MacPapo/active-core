# frozen_string_literal: true

# Devise Staff Migration
class DeviseCreateStaffs < ActiveRecord::Migration[7.1]
  def change
    create_table :staffs do |t|
      ## Database authenticatable
      t.string :nickname, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.integer    :role, default: 0, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :staffs, :nickname, unique: true
  end
end
