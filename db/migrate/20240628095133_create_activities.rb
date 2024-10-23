# frozen_string_literal: true

# Activities Migration
class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string  :name, null: false
      t.integer :num_participants, default: 0, null: false

      t.timestamps
    end

    add_index :activities, :name, unique: true
  end
end
