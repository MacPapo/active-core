class CreateWaitlists < ActiveRecord::Migration[8.0]
  def change
    create_table :waitlists do |t|
      t.references :member, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.integer :priority, default: 0, null: false

      t.timestamps
    end

    add_index :waitlists, [ :member_id, :product_id ], unique: true
    add_index :waitlists, [ :product_id, :priority ]
  end
end
