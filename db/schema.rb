# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_27_212031) do
  create_table "daily_cash_reports", force: :cascade do |t|
    t.date "report_date", null: false
    t.decimal "total_cash", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_card", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_bank_transfer", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_income", precision: 8, scale: 2, default: "0.0"
    t.decimal "total_expenses", precision: 8, scale: 2, default: "0.0"
    t.decimal "net_total", precision: 8, scale: 2, default: "0.0"
    t.integer "transaction_count", default: 0
    t.integer "membership_sales", default: 0
    t.integer "activity_registrations", default: 0
    t.integer "package_sales", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["report_date"], name: "index_daily_cash_reports_on_report_date", unique: true
  end

  create_table "discounts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "discount_type", default: 0, null: false
    t.decimal "value", precision: 8, scale: 2, null: false
    t.decimal "max_amount", precision: 8, scale: 2
    t.date "valid_from"
    t.date "valid_until"
    t.boolean "stackable", default: true, null: false
    t.integer "applicable_to", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.integer "payment_discounts_count", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicable_to"], name: "index_discounts_on_applicable_to"
    t.index ["discarded_at"], name: "index_discounts_on_discarded_at"
    t.index ["name"], name: "index_discounts_on_name", unique: true, where: "discarded_at IS NULL"
  end

  create_table "legal_guardians", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.date "birth_day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_legal_guardians_on_email", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "cf"
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email"
    t.string "phone"
    t.date "birth_day"
    t.date "med_cert_issue_date"
    t.boolean "affiliated", default: false, null: false
    t.integer "legal_guardian_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_members_on_discarded_at"
    t.index ["email"], name: "index_members_on_email", unique: true, where: "email IS NOT NULL"
    t.index ["legal_guardian_id"], name: "index_members_on_legal_guardian_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "member_id", null: false
    t.integer "pricing_plan_id", null: false
    t.integer "renewed_from_id"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.date "billing_period_start", null: false
    t.date "billing_period_end", null: false
    t.integer "status", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_memberships_on_discarded_at"
    t.index ["member_id"], name: "index_memberships_on_member_id"
    t.index ["pricing_plan_id"], name: "index_memberships_on_pricing_plan_id"
    t.index ["renewed_from_id"], name: "index_memberships_on_renewed_from_id"
    t.index ["start_date", "end_date"], name: "index_memberships_on_start_date_and_end_date"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "package_inclusions", force: :cascade do |t|
    t.integer "package_id", null: false
    t.integer "product_id", null: false
    t.integer "access_type", default: 0, null: false
    t.integer "session_limit"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_type"], name: "index_package_inclusions_on_access_type"
    t.index ["package_id", "product_id"], name: "index_package_inclusions_on_package_id_and_product_id", unique: true
    t.index ["package_id"], name: "index_package_inclusions_on_package_id"
    t.index ["product_id"], name: "index_package_inclusions_on_product_id"
  end

  create_table "package_purchases", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "package_id", null: false
    t.integer "user_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.date "billing_period_start", null: false
    t.date "billing_period_end", null: false
    t.integer "status", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_package_purchases_on_discarded_at"
    t.index ["member_id"], name: "index_package_purchases_on_member_id"
    t.index ["package_id"], name: "index_package_purchases_on_package_id"
    t.index ["status"], name: "index_package_purchases_on_status"
    t.index ["user_id"], name: "index_package_purchases_on_user_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.decimal "affiliated_price", precision: 8, scale: 2
    t.integer "duration_type", default: 0, null: false
    t.integer "duration_value", null: false
    t.date "valid_from"
    t.date "valid_until"
    t.boolean "active", default: true, null: false
    t.integer "max_sales"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_packages_on_discarded_at"
    t.index ["name"], name: "index_packages_on_name", unique: true, where: "discarded_at IS NULL"
  end

  create_table "payment_discounts", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.integer "discount_id", null: false
    t.decimal "discount_amount", precision: 8, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discount_id"], name: "index_payment_discounts_on_discount_id"
    t.index ["payment_id", "discount_id"], name: "index_payment_discounts_on_payment_id_and_discount_id", unique: true
    t.index ["payment_id"], name: "index_payment_discounts_on_payment_id"
  end

  create_table "payment_items", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.string "payable_type", null: false
    t.integer "payable_id", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_payment_items_on_discarded_at"
    t.index ["payable_type", "payable_id"], name: "index_payment_items_on_payable_type_and_payable_id"
    t.index ["payment_id"], name: "index_payment_items_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "total_amount", precision: 8, scale: 2, null: false
    t.decimal "discount_amount", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "final_amount", precision: 8, scale: 2, null: false
    t.date "date", null: false
    t.integer "payment_method", default: 0, null: false
    t.boolean "income", default: true, null: false
    t.text "notes"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_payments_on_date"
    t.index ["discarded_at"], name: "index_payments_on_discarded_at"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "pricing_plans", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "duration_type", null: false
    t.integer "duration_value"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.decimal "affiliated_price", precision: 8, scale: 2
    t.date "valid_from"
    t.date "valid_until"
    t.boolean "active", default: true, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_pricing_plans_on_discarded_at"
    t.index ["duration_type"], name: "index_pricing_plans_on_duration_type"
    t.index ["product_id"], name: "index_pricing_plans_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "product_type", null: false
    t.text "description"
    t.integer "capacity"
    t.boolean "requires_membership", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["name", "product_type"], name: "index_products_on_name_and_product_type", unique: true, where: "discarded_at IS NULL"
    t.index ["product_type"], name: "index_products_on_product_type"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.integer "user_id", null: false
    t.integer "number", null: false
    t.integer "year", null: false
    t.date "date", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_receipts_on_discarded_at"
    t.index ["number", "year"], name: "index_receipts_on_number_and_year", unique: true
    t.index ["payment_id"], name: "index_receipts_on_payment_id"
    t.index ["user_id"], name: "index_receipts_on_user_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "member_id", null: false
    t.integer "product_id", null: false
    t.integer "pricing_plan_id", null: false
    t.integer "package_id"
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.date "billing_period_start", null: false
    t.date "billing_period_end", null: false
    t.integer "sessions_remaining"
    t.integer "status", default: 0, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_registrations_on_discarded_at"
    t.index ["member_id"], name: "index_registrations_on_member_id"
    t.index ["package_id"], name: "index_registrations_on_package_id"
    t.index ["pricing_plan_id"], name: "index_registrations_on_pricing_plan_id"
    t.index ["product_id"], name: "index_registrations_on_product_id"
    t.index ["status"], name: "index_registrations_on_status"
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "role", default: 0, null: false
    t.integer "member_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["member_id"], name: "index_users_on_member_id"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  create_table "waitlists", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "product_id", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id", "product_id"], name: "index_waitlists_on_member_id_and_product_id", unique: true
    t.index ["member_id"], name: "index_waitlists_on_member_id"
    t.index ["product_id", "priority"], name: "index_waitlists_on_product_id_and_priority"
    t.index ["product_id"], name: "index_waitlists_on_product_id"
  end

  add_foreign_key "members", "legal_guardians"
  add_foreign_key "memberships", "members"
  add_foreign_key "memberships", "memberships", column: "renewed_from_id"
  add_foreign_key "memberships", "pricing_plans"
  add_foreign_key "memberships", "users"
  add_foreign_key "package_inclusions", "packages"
  add_foreign_key "package_inclusions", "products"
  add_foreign_key "package_purchases", "members"
  add_foreign_key "package_purchases", "packages"
  add_foreign_key "package_purchases", "users"
  add_foreign_key "payment_discounts", "discounts"
  add_foreign_key "payment_discounts", "payments"
  add_foreign_key "payment_items", "payments"
  add_foreign_key "payments", "users"
  add_foreign_key "pricing_plans", "products"
  add_foreign_key "receipts", "payments"
  add_foreign_key "receipts", "users"
  add_foreign_key "registrations", "members"
  add_foreign_key "registrations", "packages"
  add_foreign_key "registrations", "pricing_plans"
  add_foreign_key "registrations", "products"
  add_foreign_key "registrations", "users"
  add_foreign_key "users", "members"
  add_foreign_key "waitlists", "members"
  add_foreign_key "waitlists", "products"
end
