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

ActiveRecord::Schema[8.1].define(version: 2026_07_13_012644) do
  create_table "community_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_community_roles_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_community_roles_on_user_id"
  end

  create_table "discourse_group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "discourse_group_id", null: false
    t.string "discourse_group_name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "discourse_group_id"], name: "index_discourse_memberships_on_user_and_group", unique: true
    t.index ["user_id"], name: "index_discourse_group_memberships_on_user_id"
  end

  create_table "discourse_groups", force: :cascade do |t|
    t.string "community_role_name", null: false
    t.datetime "created_at", null: false
    t.integer "discourse_group_id", null: false
    t.string "discourse_group_name", null: false
    t.datetime "updated_at", null: false
    t.index ["community_role_name"], name: "index_discourse_groups_on_community_role_name", unique: true
    t.index ["discourse_group_id"], name: "index_discourse_groups_on_discourse_group_id", unique: true
    t.index ["discourse_group_name"], name: "index_discourse_groups_on_discourse_group_name", unique: true
  end

  create_table "discourse_identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "discourse_user_id"
    t.string "discourse_username", null: false
    t.string "external_id", null: false
    t.text "last_sync_error"
    t.string "last_sync_status", default: "pending", null: false
    t.datetime "last_synced_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["discourse_user_id"], name: "index_discourse_identities_on_discourse_user_id"
    t.index ["discourse_username"], name: "index_discourse_identities_on_discourse_username"
    t.index ["external_id"], name: "index_discourse_identities_on_external_id", unique: true
    t.index ["user_id"], name: "index_discourse_identities_on_user_id"
  end

  create_table "discourse_webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "delivery_error"
    t.string "delivery_status", default: "pending", null: false
    t.string "discourse_event_id", null: false
    t.string "event_name"
    t.string "event_type", null: false
    t.json "payload", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["delivery_status"], name: "index_discourse_webhook_events_on_delivery_status"
    t.index ["discourse_event_id"], name: "index_discourse_webhook_events_on_discourse_event_id", unique: true
    t.index ["event_type"], name: "index_discourse_webhook_events_on_event_type"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "discourse_username", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "okta_uid", null: false
    t.datetime "updated_at", null: false
    t.index ["discourse_username"], name: "index_users_on_discourse_username", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["okta_uid"], name: "index_users_on_okta_uid", unique: true
  end

  add_foreign_key "community_roles", "users"
  add_foreign_key "discourse_group_memberships", "users"
  add_foreign_key "discourse_identities", "users"
end
