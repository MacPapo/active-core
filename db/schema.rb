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

ActiveRecord::Schema[7.1].define(version: 2024_07_04_191559) do
  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_courses_on_name", unique: true
  end

  create_table "legal_guardians", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email"
    t.string "phone"
    t.date "date_of_birth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.float "amount", null: false
    t.date "date", null: false
    t.string "method", null: false
    t.string "payment_type", null: false
    t.string "entry_type", null: false
    t.string "state", null: false
    t.text "note"
    t.integer "subscription_id"
    t.integer "staff_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_payments_on_staff_id"
    t.index ["subscription_id"], name: "index_payments_on_subscription_id"
    t.check_constraint "entry_type IN ('entrata', 'uscita')", name: "payments_entry_check"
    t.check_constraint "method IN ('pos', 'contanti', 'bonifico')", name: "payments_method_check"
    t.check_constraint "payment_type IN ('abbonamento', 'quota', 'altro')", name: "payments_type_check"
    t.check_constraint "state IN ('pagato', 'non_pagato')", name: "payments_state_check"
  end

  create_table "staffs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "card_expiry_date"
    t.string "password"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_staffs_on_user_id"
  end

  create_table "subscription_histories", force: :cascade do |t|
    t.date "renewal_date"
    t.date "old_end_date"
    t.date "new_end_date"
    t.string "action"
    t.integer "subscription_id", null: false
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_subscription_histories_on_staff_id"
    t.index ["subscription_id"], name: "index_subscription_histories_on_subscription_id"
  end

  create_table "subscription_types", force: :cascade do |t|
    t.text "desc"
    t.integer "duration"
    t.float "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["desc"], name: "index_subscription_types_on_desc", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.date "start"
    t.date "end"
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.integer "subscription_type_id", null: false
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_subscriptions_on_course_id"
    t.index ["subscription_type_id"], name: "index_subscriptions_on_subscription_type_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
    t.check_constraint "state IN ('attivo', 'scaduto', 'cancellato')", name: "state_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "surname", null: false
    t.string "email"
    t.string "phone"
    t.date "date_of_birth", null: false
    t.date "med_cert_exp_date"
    t.integer "legal_guardian_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_guardian_id"], name: "index_users_on_legal_guardian_id"
  end

  add_foreign_key "payments", "staffs"
  add_foreign_key "payments", "subscriptions"
  add_foreign_key "staffs", "users"
  add_foreign_key "subscription_histories", "staffs"
  add_foreign_key "subscription_histories", "subscriptions"
  add_foreign_key "subscriptions", "courses"
  add_foreign_key "subscriptions", "subscription_types"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "legal_guardians"
end
