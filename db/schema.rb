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

ActiveRecord::Schema.define(:version => 20120706035506) do

  create_table "fulfillments", :force => true do |t|
    t.text     "line_items"
    t.text     "address"
    t.integer  "order_id"
    t.string   "message"
    t.string   "email"
    t.string   "shipping_method"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "setting_id"
  end

  add_index "fulfillments", ["setting_id"], :name => "index_fulfillments_on_setting_id"

  create_table "settings", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.boolean  "automatic_fulfillment"
    t.string   "shop_id"
    t.string   "token"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "variants", :force => true do |t|
    t.integer  "variant_id"
    t.integer  "setting_id"
    t.integer  "inventory"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "activated"
    t.string   "sku"
  end

  add_index "variants", ["setting_id"], :name => "index_synced_variants_on_setting_id"

end
