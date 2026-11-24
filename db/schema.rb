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

ActiveRecord::Schema[7.2].define(version: 2026_11_22_234421) do
  create_table "admins", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "callback_notes", force: :cascade do |t|
    t.integer "callback_request_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["callback_request_id"], name: "index_callback_notes_on_callback_request_id"
  end

  create_table "callback_requests", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.boolean "processed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_favorites_on_product_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.check_constraint "quantity > 0", name: "order_items_quantity_positive"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_name", null: false
    t.string "phone", null: false
    t.string "email"
    t.string "address", null: false
    t.string "delivery", null: false
    t.string "payment", null: false
    t.string "status", default: "Нове", null: false
    t.decimal "total", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "gift_recipient_name"
    t.string "gift_recipient_phone"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "manufacturer", null: false
    t.string "model_number"
    t.text "description"
    t.decimal "price", default: "0.0", null: false
    t.integer "stock", default: 0, null: false
    t.string "load_type"
    t.decimal "capacity"
    t.integer "spin_speed"
    t.string "energy_class"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.boolean "gift_card"
    t.integer "reviews_count"
    t.integer "rating_sum"
    t.index ["active"], name: "index_products_on_active"
    t.index ["energy_class"], name: "index_products_on_energy_class"
    t.index ["load_type"], name: "index_products_on_load_type"
    t.index ["manufacturer", "model_number"], name: "index_products_on_manufacturer_and_model_number", unique: true
    t.index ["price"], name: "index_products_on_price"
    t.index ["spin_speed"], name: "index_products_on_spin_speed"
    t.check_constraint "price >= 0", name: "products_price_non_negative"
    t.check_constraint "stock >= 0", name: "products_stock_non_negative"
  end

  create_table "promotion_products", force: :cascade do |t|
    t.integer "promotion_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_promotion_products_on_product_id"
    t.index ["promotion_id"], name: "index_promotion_products_on_promotion_id"
  end

  create_table "promotions", force: :cascade do |t|
    t.string "title"
    t.string "kind"
    t.text "description"
    t.text "conditions"
    t.string "image_url"
    t.integer "discount_percent"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.index ["product_id"], name: "index_promotions_on_product_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "user_id", null: false
    t.integer "rating"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "callback_notes", "callback_requests"
  add_foreign_key "favorites", "products"
  add_foreign_key "favorites", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "promotion_products", "products"
  add_foreign_key "promotion_products", "promotions"
  add_foreign_key "promotions", "products"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
end
