class CreatePricingPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :pricing_plans do |t|
      t.references :product, null: false, foreign_key: true

      t.integer :duration_type, null: false
      t.integer :duration_value
      t.decimal :price, precision: 8, scale: 2, null: false
      t.decimal :affiliated_price, precision: 8, scale: 2
      t.date :valid_from
      t.date :valid_until
      t.boolean :active, default: true, null: false


      t.datetime :discarded_at
      t.timestamps
    end

    add_index :pricing_plans, :duration_type
    add_index :pricing_plans, :discarded_at
  end
end
