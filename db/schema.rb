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

ActiveRecord::Schema.define(:version => 20130217123332) do

  create_table "items", :force => true do |t|
    t.integer "parent_id"
    t.integer "lftp",                                      :null => false
    t.integer "lftq",                                      :null => false
    t.integer "rgtp",                                      :null => false
    t.integer "rgtq",                                      :null => false
    t.decimal "lft",       :precision => 31, :scale => 30, :null => false
    t.decimal "rgt",       :precision => 31, :scale => 30, :null => false
    t.string  "name",                                      :null => false
    t.integer "map_id"
  end

  add_index "items", ["lft"], :name => "index_items_on_lft"
  add_index "items", ["lftp"], :name => "index_items_on_lftp"
  add_index "items", ["lftq"], :name => "index_items_on_lftq"
  add_index "items", ["parent_id"], :name => "index_items_on_parent_id"
  add_index "items", ["rgt"], :name => "index_items_on_rgt"

  create_table "maps", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
