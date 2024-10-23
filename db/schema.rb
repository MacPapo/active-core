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

ActiveRecord::Schema[7.1].define(version: 2024_10_10_080023) do
  create_table "activities", force: :cascade do |t|
    t.string "name", null: false
    t.integer "num_participants", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_activities_on_discarded_at"
    t.index ["name"], name: "index_activities_on_name", unique: true
  end

  create_table "activity_plans", force: :cascade do |t|
    t.integer "plan", default: 0, null: false
    t.decimal "cost", precision: 8, scale: 2, null: false
    t.decimal "affiliated_cost", precision: 8, scale: 2
    t.integer "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["activity_id"], name: "index_activity_plans_on_activity_id"
    t.index ["discarded_at"], name: "index_activity_plans_on_discarded_at"
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

  create_table "memberships", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_memberships_on_discarded_at"
    t.index ["staff_id"], name: "index_memberships_on_staff_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "payment_memberships", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.integer "membership_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_payment_memberships_on_discarded_at"
    t.index ["membership_id"], name: "index_payment_memberships_on_membership_id"
    t.index ["payment_id", "id"], name: "index_payment_memberships_on_payment_id_and_id", unique: true
    t.index ["payment_id"], name: "index_payment_memberships_on_payment_id"
    t.index ["user_id"], name: "index_payment_memberships_on_user_id"
  end

  create_table "payment_subscriptions", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.integer "subscription_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_payment_subscriptions_on_discarded_at"
    t.index ["payment_id", "id"], name: "index_payment_subscriptions_on_payment_id_and_id", unique: true
    t.index ["payment_id"], name: "index_payment_subscriptions_on_payment_id"
    t.index ["subscription_id"], name: "index_payment_subscriptions_on_subscription_id"
    t.index ["user_id"], name: "index_payment_subscriptions_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.date "date", null: false
    t.integer "method", default: 0, null: false
    t.boolean "income", default: true, null: false
    t.text "note"
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_payments_on_discarded_at"
    t.index ["staff_id"], name: "index_payments_on_staff_id"
  end

  create_table "receipt_memberships", force: :cascade do |t|
    t.integer "receipt_id", null: false
    t.integer "membership_id", null: false
    t.integer "user_id", null: false
    t.integer "number", default: 0, null: false
    t.integer "year", default: 2024, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_receipt_memberships_on_discarded_at"
    t.index ["membership_id"], name: "index_receipt_memberships_on_membership_id"
    t.index ["receipt_id", "id"], name: "index_receipt_memberships_on_receipt_id_and_id", unique: true
    t.index ["receipt_id"], name: "index_receipt_memberships_on_receipt_id"
    t.index ["user_id"], name: "index_receipt_memberships_on_user_id"
  end

  create_table "receipt_subscriptions", force: :cascade do |t|
    t.integer "receipt_id", null: false
    t.integer "subscription_id", null: false
    t.integer "user_id", null: false
    t.integer "number", default: 0, null: false
    t.integer "year", default: 2024, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_receipt_subscriptions_on_discarded_at"
    t.index ["receipt_id", "id"], name: "index_receipt_subscriptions_on_receipt_id_and_id", unique: true
    t.index ["receipt_id"], name: "index_receipt_subscriptions_on_receipt_id"
    t.index ["subscription_id"], name: "index_receipt_subscriptions_on_subscription_id"
    t.index ["user_id"], name: "index_receipt_subscriptions_on_user_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.date "date", null: false
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_receipts_on_discarded_at"
    t.index ["payment_id"], name: "index_receipts_on_payment_id"
    t.index ["staff_id"], name: "index_receipts_on_staff_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "nickname", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "role", default: 0, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_staffs_on_discarded_at"
    t.index ["nickname"], name: "index_staffs_on_nickname", unique: true
    t.index ["user_id"], name: "index_staffs_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "activity_id", null: false
    t.integer "activity_plan_id", null: false
    t.integer "staff_id", null: false
    t.integer "open_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["activity_id"], name: "index_subscriptions_on_activity_id"
    t.index ["activity_plan_id"], name: "index_subscriptions_on_activity_plan_id"
    t.index ["discarded_at"], name: "index_subscriptions_on_discarded_at"
    t.index ["open_subscription_id"], name: "index_subscriptions_on_open_subscription_id"
    t.index ["staff_id"], name: "index_subscriptions_on_staff_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "cf"
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email"
    t.string "phone"
    t.date "birth_day"
    t.date "med_cert_issue_date"
    t.boolean "affiliated", default: false, null: false
    t.integer "legal_guardian_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["legal_guardian_id"], name: "index_users_on_legal_guardian_id"
  end

  create_table "waitlists", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_waitlists_on_activity_id"
    t.index ["user_id"], name: "index_waitlists_on_user_id"
  end

  add_foreign_key "activity_plans", "activities"
  add_foreign_key "memberships", "staffs"
  add_foreign_key "memberships", "users"
  add_foreign_key "payment_memberships", "memberships"
  add_foreign_key "payment_memberships", "payments"
  add_foreign_key "payment_memberships", "users"
  add_foreign_key "payment_subscriptions", "payments"
  add_foreign_key "payment_subscriptions", "subscriptions"
  add_foreign_key "payment_subscriptions", "users"
  add_foreign_key "payments", "staffs"
  add_foreign_key "receipt_memberships", "memberships"
  add_foreign_key "receipt_memberships", "receipts"
  add_foreign_key "receipt_memberships", "users"
  add_foreign_key "receipt_subscriptions", "receipts"
  add_foreign_key "receipt_subscriptions", "subscriptions"
  add_foreign_key "receipt_subscriptions", "users"
  add_foreign_key "receipts", "payments"
  add_foreign_key "receipts", "staffs"
  add_foreign_key "staffs", "users"
  add_foreign_key "subscriptions", "activities"
  add_foreign_key "subscriptions", "activity_plans"
  add_foreign_key "subscriptions", "staffs"
  add_foreign_key "subscriptions", "subscriptions", column: "open_subscription_id"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "legal_guardians"
  add_foreign_key "waitlists", "activities"
  add_foreign_key "waitlists", "users"
end
