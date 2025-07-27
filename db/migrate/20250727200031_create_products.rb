class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :product_type, null: false
      t.text :description
      t.integer :capacity
      t.boolean :requires_membership, default: true, null: false
      t.boolean :active, default: true, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :products, [:name, :product_type], unique: true, where: "discarded_at IS NULL"
    add_index :products, :product_type
    add_index :products, :discarded_at
  end
end
