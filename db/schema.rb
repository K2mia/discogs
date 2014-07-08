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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140707183344) do

  create_table "keywords", :force => true do |t|
    t.string   "keys"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "keywords", ["user_id", "created_at"], :name => "index_keywords_on_user_id_and_created_at"

  create_table "prices", :force => true do |t|
    t.integer  "keyword_id"
    t.string   "ebay_id"
    t.string   "price"
    t.boolean  "ended"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "prices", ["ebay_id"], :name => "index_prices_on_ebay_id"
  add_index "prices", ["ended"], :name => "index_prices_on_ended"
  add_index "prices", ["keyword_id"], :name => "index_prices_on_keyword_id"

  create_table "releases", :force => true do |t|
    t.integer  "keyword_id"
    t.string   "label"
    t.string   "format"
    t.string   "country"
    t.string   "released"
    t.string   "genre"
    t.string   "style"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "releases", ["format"], :name => "index_releases_on_format"
  add_index "releases", ["genre"], :name => "index_releases_on_genre"
  add_index "releases", ["keyword_id"], :name => "index_releases_on_keyword_id"
  add_index "releases", ["label"], :name => "index_releases_on_label"
  add_index "releases", ["style"], :name => "index_releases_on_style"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
