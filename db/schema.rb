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

ActiveRecord::Schema.define(version: 20130412140850) do

  create_table "events", force: true do |t|
    t.string   "name",       null: false
    t.string   "series",     null: false
    t.datetime "date",       null: false
    t.string   "uri",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "match_sets", force: true do |t|
    t.integer  "gom_id"
    t.integer  "event_id"
    t.integer  "index"
    t.text     "players"
    t.string   "map"
    t.string   "uri"
    t.string   "forum_thread_uri"
    t.string   "league"
    t.integer  "round"
    t.string   "group"
    t.text     "ratings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
