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

ActiveRecord::Schema.define(version: 20150709001207) do

  create_table "domains", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "active",      default: "Y"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id"
    t.integer  "provider_id"
  end

  add_index "domains", ["name"], name: "index_domains_on_name", unique: true

  create_table "providers", force: :cascade do |t|
    t.string "name",                           null: false
    t.string "slug",                           null: false
    t.text   "characteristics", default: "{}"
  end

  add_index "providers", ["slug"], name: "index_providers_on_slug", unique: true

  create_table "records", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "name",                                 null: false
    t.string   "zone_type",                            null: false
    t.string   "data"
    t.integer  "priority"
    t.integer  "port"
    t.integer  "weight"
    t.string   "active",                 default: "Y"
    t.datetime "modification_timestamp"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid"

end
