class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :nickname, null: false
      t.string :encrypted_password, null: false, default: ''

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.integer    :role, default: 0, null: false
      t.references :member, null: false, foreign_key: true

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :users, :nickname, unique: true
    add_index :users, :discarded_at
  end
end
