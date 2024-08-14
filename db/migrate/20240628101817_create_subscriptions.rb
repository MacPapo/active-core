class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.date       :start_date          , null: false
      t.date       :end_date            , null: false
      t.integer    :status              , default: 0, null: false
      t.boolean    :open                , default: false, null: true

      t.references :user                , null: false, foreign_key: true
      t.references :activity            , null: false, foreign_key: true
      t.references :activity_plan       , null: false, foreign_key: true
      t.references :staff               , null: false, foreign_key: true

      t.timestamps
    end
  end
end
