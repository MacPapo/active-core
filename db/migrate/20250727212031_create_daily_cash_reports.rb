class CreateDailyCashReports < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_cash_reports do |t|
      t.date :report_date, null: false
      t.decimal :total_cash, precision: 8, scale: 2, default: 0
      t.decimal :total_card, precision: 8, scale: 2, default: 0
      t.decimal :total_bank_transfer, precision: 8, scale: 2, default: 0
      t.decimal :total_income, precision: 8, scale: 2, default: 0
      t.decimal :total_expenses, precision: 8, scale: 2, default: 0
      t.decimal :net_total, precision: 8, scale: 2, default: 0
      t.integer :transaction_count, default: 0
      t.integer :membership_sales, default: 0
      t.integer :activity_registrations, default: 0
      t.integer :package_sales, default: 0

      t.timestamps
    end

    add_index :daily_cash_reports, :report_date, unique: true
  end
end
