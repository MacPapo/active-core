class CreatePackages < ActiveRecord::Migration[8.0]
  def change
    create_table :packages do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 8, scale: 2, null: false
      t.decimal :affiliated_price, precision: 8, scale: 2
      t.integer :duration_type, default: 0, null: false
      t.integer :duration_value, null: false
      t.date :valid_from
      t.date :valid_until
      t.boolean :active, default: true, null: false
      t.integer :max_sales

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :packages, :name, unique: true, where: "discarded_at IS NULL"
    add_index :packages, :discarded_at
  end
end
