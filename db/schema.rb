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

ActiveRecord::Schema[8.0].define(version: 2025_08_06_192742) do
  create_table "access_grants", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "user_id"
    t.integer "package_id"
    t.integer "pricing_plan_id"
    t.integer "renewed_from_id"
    t.integer "status", default: 0, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_access_grants_on_member_id"
    t.index ["package_id", "pricing_plan_id"], name: "index_access_grants_on_package_id_and_pricing_plan_id"
    t.index ["package_id"], name: "index_access_grants_on_package_id"
    t.index ["pricing_plan_id"], name: "index_access_grants_on_pricing_plan_id"
    t.index ["renewed_from_id"], name: "index_access_grants_on_renewed_from_id"
    t.index ["status", "end_date"], name: "index_access_grants_on_status_and_end_date"
    t.index ["user_id"], name: "index_access_grants_on_user_id"
    t.check_constraint "(package_id IS NOT NULL AND pricing_plan_id IS NULL) OR (package_id IS NULL AND pricing_plan_id IS NOT NULL)", name: "grant_has_one_source"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "discount_type", default: 0, null: false
    t.decimal "value", precision: 8, scale: 2, null: false
    t.date "valid_from"
    t.date "valid_until"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_discounts_on_discarded_at"
    t.index ["name"], name: "index_discounts_on_name", unique: true, where: "discarded_at IS NULL"
  end

  create_table "members", force: :cascade do |t|
    t.string "tax_code"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.date "birth_date"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "province"
    t.string "zip_code"
    t.date "medical_certificate_issued_on"
    t.boolean "affiliated", default: false, null: false
    t.integer "legal_guardian_id"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_members_on_discarded_at"
    t.index ["email"], name: "index_members_on_email", unique: true, where: "discarded_at IS NULL"
    t.index ["legal_guardian_id"], name: "index_members_on_legal_guardian_id"
  end

  create_table "package_inclusions", force: :cascade do |t|
    t.integer "package_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["package_id", "product_id"], name: "index_package_inclusions_on_package_id_and_product_id", unique: true
    t.index ["package_id"], name: "index_package_inclusions_on_package_id"
    t.index ["product_id"], name: "index_package_inclusions_on_product_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 8, scale: 2, null: false
    t.decimal "affiliated_price", precision: 8, scale: 2
    t.integer "duration_interval", null: false
    t.integer "duration_unit", null: false
    t.date "valid_from"
    t.date "valid_until"
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
    t.index ["payment_id"], name: "index_payment_discounts_on_payment_id"
  end

  create_table "payment_items", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.string "payable_type"
    t.integer "payable_id"
    t.string "description", null: false
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payable_type", "payable_id"], name: "index_payment_items_on_payable"
    t.index ["payment_id"], name: "index_payment_items_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "user_id", null: false
    t.integer "receipt_number"
    t.integer "receipt_year"
    t.decimal "total_amount", precision: 8, scale: 2, null: false
    t.decimal "discount_amount", precision: 8, scale: 2, default: "0.0"
    t.decimal "final_amount", precision: 8, scale: 2, null: false
    t.date "date", null: false
    t.integer "payment_method", default: 0, null: false
    t.text "notes"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_payments_on_discarded_at"
    t.index ["member_id"], name: "index_payments_on_member_id"
    t.index ["receipt_number", "receipt_year"], name: "index_payments_on_receipt_number_and_receipt_year", unique: true, where: "receipt_number IS NOT NULL"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "pricing_plans", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.decimal "affiliated_price", precision: 8, scale: 2
    t.integer "duration_interval", null: false
    t.integer "duration_unit", null: false
    t.date "valid_from"
    t.date "valid_until"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_pricing_plans_on_discarded_at"
    t.index ["product_id", "name"], name: "index_pricing_plans_on_product_id_and_name", unique: true, where: "discarded_at IS NULL"
    t.index ["product_id"], name: "index_pricing_plans_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "max_capacity"
    t.boolean "requires_medical_certificate", default: false, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_products_on_name", unique: true, where: "discarded_at IS NULL"
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
    t.index ["nickname"], name: "index_users_on_nickname", unique: true, where: "discarded_at IS NULL"
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

  add_foreign_key "access_grants", "access_grants", column: "renewed_from_id"
  add_foreign_key "access_grants", "members"
  add_foreign_key "access_grants", "packages"
  add_foreign_key "access_grants", "pricing_plans"
  add_foreign_key "access_grants", "users"
  add_foreign_key "members", "members", column: "legal_guardian_id"
  add_foreign_key "package_inclusions", "packages"
  add_foreign_key "package_inclusions", "products"
  add_foreign_key "payment_discounts", "discounts"
  add_foreign_key "payment_discounts", "payments"
  add_foreign_key "payment_items", "payments"
  add_foreign_key "payments", "members"
  add_foreign_key "payments", "users"
  add_foreign_key "pricing_plans", "products"
  add_foreign_key "users", "members"
  add_foreign_key "waitlists", "members"
  add_foreign_key "waitlists", "products"
end
