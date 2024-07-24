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

ActiveRecord::Schema[7.1].define(version: 2024_07_10_152000) do
  create_table "activities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_activities_on_name", unique: true
  end

  create_table "activity_plans", force: :cascade do |t|
    t.integer "plan", default: 0, null: false
    t.float "cost", null: false
    t.float "affiliated_cost"
    t.integer "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_plans_on_activity_id"
  end

  create_table "legal_guardians", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.date "date_of_birth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "membership_histories", force: :cascade do |t|
    t.date "renewal_date"
    t.date "old_end_date"
    t.date "new_end_date"
    t.integer "action", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "membership_id", null: false
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_membership_histories_on_membership_id"
    t.index ["staff_id"], name: "index_membership_histories_on_staff_id"
    t.index ["user_id"], name: "index_membership_histories_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_memberships_on_staff_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.float "amount", null: false
    t.date "date", null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "entry_type", default: 0, null: false
    t.boolean "payed", default: true, null: false
    t.text "note"
    t.integer "staff_id"
    t.string "payable_type"
    t.integer "payable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
    t.index ["staff_id"], name: "index_payments_on_staff_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.integer "role", default: 0
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_staffs_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staffs_on_reset_password_token", unique: true
    t.index ["user_id"], name: "index_staffs_on_user_id"
  end

  create_table "subscription_histories", force: :cascade do |t|
    t.date "renewal_date"
    t.date "old_end_date"
    t.date "new_end_date"
    t.integer "action", default: 0, null: false
    t.integer "subscription_id", null: false
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_subscription_histories_on_staff_id"
    t.index ["subscription_id"], name: "index_subscription_histories_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "activity_id"
    t.integer "activity_plan_id", null: false
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_subscriptions_on_activity_id"
    t.index ["activity_plan_id"], name: "index_subscriptions_on_activity_plan_id"
    t.index ["staff_id"], name: "index_subscriptions_on_staff_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "cf", null: false
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email"
    t.string "phone"
    t.date "date_of_birth", null: false
    t.date "med_cert_issue_date"
    t.boolean "affiliated", default: false, null: false
    t.integer "legal_guardian_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_guardian_id"], name: "index_users_on_legal_guardian_id"
  end

  add_foreign_key "activity_plans", "activities"
  add_foreign_key "membership_histories", "memberships"
  add_foreign_key "membership_histories", "staffs"
  add_foreign_key "membership_histories", "users"
  add_foreign_key "memberships", "staffs"
  add_foreign_key "memberships", "users"
  add_foreign_key "payments", "staffs"
  add_foreign_key "staffs", "users"
  add_foreign_key "subscription_histories", "staffs"
  add_foreign_key "subscription_histories", "subscriptions"
  add_foreign_key "subscriptions", "activities"
  add_foreign_key "subscriptions", "activity_plans"
  add_foreign_key "subscriptions", "staffs"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "legal_guardians"
end
