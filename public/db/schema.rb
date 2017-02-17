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

ActiveRecord::Schema.define(version: 20170216214815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balances", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "balance",    default: 0.0
    t.float    "test",       default: 0.0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "balances", ["user_id"], name: "index_balances_on_user_id", using: :btree

  create_table "charge_histories", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.string   "account_type"
    t.string   "lastfour"
    t.string   "status"
    t.string   "amount"
  end

  create_table "credit_customers", force: :cascade do |t|
    t.string   "cus_id"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "active_recharge", default: false
    t.string   "recharge_amount", default: "0"
  end

  create_table "customers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "store_id"
    t.string   "shopify_id"
    t.string   "bigcommerce_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "phone"
  end

  add_index "customers", ["store_id"], name: "index_customers_on_store_id", using: :btree
  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree

  create_table "listings", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "store_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "external_id"
    t.string   "printer_sku"
  end

  add_index "listings", ["product_id"], name: "index_listings_on_product_id", using: :btree
  add_index "listings", ["store_id"], name: "index_listings_on_store_id", using: :btree
  add_index "listings", ["user_id"], name: "index_listings_on_user_id", using: :btree

  create_table "master_product_colors", force: :cascade do |t|
    t.integer  "master_product_id"
    t.string   "external_id"
    t.string   "name"
    t.string   "image_url"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "master_product_colors", ["master_product_id"], name: "index_master_product_colors_on_master_product_id", using: :btree

  create_table "master_product_options", force: :cascade do |t|
    t.integer  "master_product_id"
    t.string   "external_id"
    t.string   "name"
    t.string   "image_url"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "master_product_options", ["master_product_id"], name: "index_master_product_options_on_master_product_id", using: :btree

  create_table "master_product_print_areas", force: :cascade do |t|
    t.integer  "master_product_id"
    t.string   "external_id"
    t.string   "name"
    t.decimal  "view_id"
    t.decimal  "view_image_url"
    t.decimal  "view_size_width"
    t.decimal  "view_size_height"
    t.decimal  "offset_x"
    t.decimal  "offset_y"
    t.decimal  "print_area_width"
    t.decimal  "print_area_height"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "master_product_print_areas", ["master_product_id"], name: "index_master_product_print_areas_on_master_product_id", using: :btree

  create_table "master_product_sizes", force: :cascade do |t|
    t.integer  "master_product_id"
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "master_product_sizes", ["master_product_id"], name: "index_master_product_sizes_on_master_product_id", using: :btree

  create_table "master_product_stock_states", force: :cascade do |t|
    t.integer  "master_product_id"
    t.string   "color"
    t.string   "size"
    t.boolean  "available"
    t.integer  "quantity"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "master_product_stock_states", ["master_product_id"], name: "index_master_product_stock_states_on_master_product_id", using: :btree

  create_table "master_product_types", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "master_products", force: :cascade do |t|
    t.integer  "master_product_type_id"
    t.integer  "printer_id"
    t.string   "external_id"
    t.string   "name"
    t.string   "short_description"
    t.text     "description"
    t.string   "default_image_url"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.decimal  "printer_price"
    t.decimal  "price"
  end

  add_index "master_products", ["master_product_type_id"], name: "index_master_products_on_master_product_type_id", using: :btree
  add_index "master_products", ["printer_id"], name: "index_master_products_on_printer_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notes", ["order_id"], name: "index_notes_on_order_id", using: :btree
  add_index "notes", ["user_id"], name: "index_notes_on_user_id", using: :btree

  create_table "order_line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "listing_id"
    t.integer  "quantity"
    t.decimal  "price"
    t.string   "status"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "printer_order_id"
    t.string   "tracking"
    t.integer  "user_id"
    t.string   "external_id"
    t.string   "tracking_url"
    t.string   "shipping_type"
    t.string   "shipping_description"
    t.string   "fulfillment_sync_status"
    t.integer  "master_product_color_id"
    t.integer  "master_product_size_id"
  end

  add_index "order_line_items", ["listing_id"], name: "index_order_line_items_on_listing_id", using: :btree
  add_index "order_line_items", ["order_id"], name: "index_order_line_items_on_order_id", using: :btree
  add_index "order_line_items", ["printer_order_id"], name: "index_order_line_items_on_printer_order_id", using: :btree
  add_index "order_line_items", ["user_id"], name: "index_order_line_items_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "store_id"
    t.string   "external_order_id"
    t.string   "external_order_name"
    t.datetime "order_date"
    t.integer  "print_status"
    t.string   "tracking"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "customer_id"
    t.decimal  "price",                 precision: 10, scale: 2
    t.string   "status"
    t.datetime "completed_at"
    t.string   "shipping_name"
    t.string   "shipping_address"
    t.string   "shipping_address2"
    t.string   "shipping_city"
    t.string   "shipping_state"
    t.string   "shipping_postal_code"
    t.string   "shipping_country"
    t.string   "shipping_country_code"
    t.string   "shipping_state_code"
    t.boolean  "fund_status",                                    default: false
  end

  add_index "orders", ["store_id"], name: "index_orders_on_store_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "printer_orders", force: :cascade do |t|
    t.integer  "printer_id"
    t.string   "status"
    t.datetime "submitted_at"
    t.datetime "completed_at"
    t.string   "tracking"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "external_id"
  end

  add_index "printer_orders", ["printer_id"], name: "index_printer_orders_on_printer_id", using: :btree

  create_table "printers", force: :cascade do |t|
    t.string   "printer_type"
    t.string   "name"
    t.string   "api_key"
    t.string   "api_secret"
    t.string   "user"
    t.string   "password"
    t.string   "url"
    t.string   "external_shop_id"
    t.string   "account"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "product_variant_images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "name"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "product_variant_images", ["product_id"], name: "index_product_variant_images_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "print_image"
    t.string   "product_image"
    t.decimal  "price",                        precision: 10, scale: 2
    t.integer  "master_product_id"
    t.integer  "master_product_size_id"
    t.integer  "master_product_option_id"
    t.integer  "master_product_print_area_id"
    t.decimal  "print_image_x_offset"
    t.decimal  "print_image_y_offset"
    t.decimal  "print_image_width"
    t.decimal  "print_image_height"
    t.string   "product_size_ids"
    t.string   "product_color_ids"
  end

  add_index "products", ["master_product_id"], name: "index_products_on_master_product_id", using: :btree
  add_index "products", ["master_product_option_id"], name: "index_products_on_master_product_option_id", using: :btree
  add_index "products", ["master_product_print_area_id"], name: "index_products_on_master_product_print_area_id", using: :btree
  add_index "products", ["master_product_size_id"], name: "index_products_on_master_product_size_id", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "shops", force: :cascade do |t|
    t.string   "shop_name"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "contact_phone2"
    t.string   "contact_address"
    t.string   "contact_address2"
    t.string   "contact_city"
    t.string   "contact_state_province"
    t.string   "contact_postal_code"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "contact_email"
  end

  create_table "stores", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "description"
    t.string   "api_key"
    t.string   "api_secret"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "store_type"
    t.string   "api_path"
  end

  add_index "stores", ["user_id"], name: "index_stores_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.integer  "shop_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["shop_id"], name: "index_users_on_shop_id", using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

end
