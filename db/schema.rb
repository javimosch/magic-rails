# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160428122613) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "additional_address"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "delivery_request_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "availabilities", force: :cascade do |t|
    t.integer  "schedule_id"
    t.integer  "shop_id"
    t.integer  "deliveryman_id"
    t.boolean  "enabled"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "delivery_id"
    t.boolean  "match",          default: false
  end

  create_table "commissions", force: :cascade do |t|
    t.float    "percentage"
    t.float    "shipping_percentage"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.string   "status",              default: "pending"
    t.string   "validation_code"
    t.float    "total"
    t.float    "commission"
    t.integer  "payin_id"
    t.integer  "availability_id"
    t.integer  "delivery_request_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.float    "shipping_total"
  end

  create_table "delivery_contents", force: :cascade do |t|
    t.integer  "id_delivery"
    t.integer  "id_product"
    t.integer  "quantity"
    t.float    "unit_price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "delivery_requests", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "schedule_id"
    t.integer  "shop_id"
    t.integer  "address_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "match",       default: false
    t.integer  "delivery_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "mode"
    t.string   "title"
    t.text     "content"
    t.string   "sender"
    t.integer  "user_id"
    t.string   "meta"
    t.boolean  "read"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "delivery_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "to_user_id"
    t.integer  "from_user_id"
    t.integer  "rating"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "delivery_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string   "schedule"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.boolean  "share_phone",            default: true
    t.string   "avatar"
    t.float    "rating_average"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "auth_method",            default: "email"
    t.string   "auth_token"
    t.integer  "wallet_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wallets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "lemonway_id"
    t.string   "credit_card_display"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "lemonway_card_id"
  end

end
