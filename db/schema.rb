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

ActiveRecord::Schema.define(:version => 20120814193507) do

  create_table "fulfillment_line_items", :force => true do |t|
    t.integer  "line_item_id"
    t.integer  "fulfillment_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "fulfillments", :force => true do |t|
    t.string   "email"
    t.string   "shipping_method"
    t.string   "status"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "shopify_fulfillment_id"
    t.string   "warehouse"
    t.integer  "order_id"
    t.integer  "shop_id"
    t.string   "tracking_carrier"
    t.string   "tracking_link"
    t.integer  "tracking_number"
    t.datetime "ship_date"
    t.datetime "expected_delivery_date"
    t.datetime "return_date"
    t.string   "return_condition"
    t.string   "shipper_name"
    t.string   "total"
    t.string   "returned"
    t.string   "shipped"
    t.integer  "fulfillment_id"
    t.string   "shipwire_order_id"
    t.decimal  "origin_lat"
    t.decimal  "origin_long"
    t.decimal  "destination_lat"
    t.decimal  "destination_long"
  end

  create_table "line_items", :force => true do |t|
    t.string   "fulfillment_service"
    t.string   "fulfillment_status"
    t.integer  "grams"
    t.integer  "line_item_id"
    t.string   "price"
    t.integer  "product_id",          :null => false
    t.integer  "quantity"
    t.string   "sku"
    t.string   "title"
    t.integer  "variant_id",          :null => false
    t.string   "variant_title"
    t.string   "vendor"
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "order_id"
    t.boolean  "requires_shipping"
  end

  create_table "orders", :force => true do |t|
    t.integer  "shopify_order_id"
    t.string   "email"
    t.integer  "number"
    t.integer  "total_weight"
    t.string   "currency"
    t.string   "financial_status"
    t.boolean  "confirmed",          :default => false
    t.string   "fulfillment_status"
    t.string   "name"
    t.datetime "cancelled_at"
    t.string   "cancel_reason"
    t.decimal  "total_price"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "shop_id"
  end

  create_table "shipping_addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.string   "province"
    t.string   "country"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "order_id"
  end

  create_table "shops", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.boolean  "automatic_fulfillment"
    t.string   "token"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "domain"
    t.boolean  "valid_credentials",     :default => false
  end

  create_table "variants", :force => true do |t|
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "sku"
    t.integer  "shop_id"
    t.integer  "shopify_variant_id"
    t.string   "backordered"
    t.string   "reserved"
    t.string   "shipping"
    t.string   "shipped"
    t.string   "availableDate"
    t.string   "shippedLastDay"
    t.string   "shippedLastWeek"
    t.string   "shippedLast4Weeks"
    t.string   "orderedLastDay"
    t.string   "orderedLastWeek"
    t.string   "orderedLast4Weeks"
    t.string   "title"
    t.integer  "quantity"
  end

end
