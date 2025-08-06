class CreatePackages < ActiveRecord::Migration[8.0]
  def change
    create_table :packages do |t|
      t.string :name, null: false
      t.text :description

      # Price
      t.decimal :price, precision: 8, scale: 2, null: false
      t.decimal :affiliated_price, precision: 8, scale: 2

      # Duration (Standardized)
      t.integer :duration_interval, null: false # e.g., 1, 3
      t.integer :duration_unit, null: false     # e.g., 'month', 'year'

      # Validity Period of the package itself
      t.date :valid_from
      t.date :valid_until

      # Sales Limit
      t.integer :max_sales

      t.datetime :discarded_at, index: true
      t.timestamps
    end

    add_index :packages, :name, unique: true, where: "discarded_at IS NULL"
  end
end
