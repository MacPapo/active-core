class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :max_capacity
      t.boolean :requires_medical_certificate, default: false, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :products, :name, unique: true, where: "discarded_at IS NULL"
  end
end
