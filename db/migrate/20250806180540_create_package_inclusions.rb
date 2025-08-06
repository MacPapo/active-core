class CreatePackageInclusions < ActiveRecord::Migration[8.0]
  def change
    create_table :package_inclusions do |t|
      t.references :package, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :package_inclusions, [ :package_id, :product_id ], unique: true
  end
end
