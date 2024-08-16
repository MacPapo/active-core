# frozen_string_literal: true

class CreateWaitlists < ActiveRecord::Migration[7.1]
  def change
    create_table :waitlists do |t|
      t.references :user     , null: false, foreign_key: true
      t.references :activity , null: false, foreign_key: true

      t.timestamps
    end
  end
end
