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

ActiveRecord::Schema[8.0].define(version: 2025_05_27_080034) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "aws_credential_sets", force: :cascade do |t|
    t.string "access_key_id"
    t.string "secret_access_key"
    t.string "session_token"
    t.datetime "expires_at"
    t.integer "tax_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_account_id"], name: "index_aws_credential_sets_on_tax_account_id"
  end

  create_table "jwt_token_sets", force: :cascade do |t|
    t.string "access_token"
    t.datetime "access_token_expires_at"
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.string "aws_token"
    t.datetime "aws_token_expires_at"
    t.string "identity_id"
    t.integer "tax_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_account_id"], name: "index_jwt_token_sets_on_tax_account_id"
  end

  create_table "meli_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "mercadolibre_identifier"
    t.string "nickname"
    t.string "site_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_meli_accounts_on_user_id"
  end

  create_table "meli_auth_tokens", force: :cascade do |t|
    t.integer "meli_account_id", null: false
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meli_account_id"], name: "index_meli_auth_tokens_on_meli_account_id"
  end

  create_table "meli_notifications", force: :cascade do |t|
    t.string "resource"
    t.integer "meli_user_id"
    t.string "topic"
    t.integer "application_id"
    t.integer "attempts"
    t.datetime "sent"
    t.datetime "received"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_meli_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.string "item_id"
    t.string "seller_sku"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sale_channel_id"
    t.integer "billable_amount"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "pack_id"
    t.string "human_readable_id"
    t.integer "source_channel", default: 0
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "billable_amount"
    t.integer "expected_item_count"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inventory_count"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "meli_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "logistic_type"
    t.integer "billable_amount"
    t.string "destination"
    t.datetime "delivery_deadline"
    t.index ["order_id"], name: "index_shipments_on_order_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_subscribers_on_product_id"
  end

  create_table "tax_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "rut"
    t.string "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tax_accounts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "aws_credential_sets", "tax_accounts"
  add_foreign_key "jwt_token_sets", "tax_accounts"
  add_foreign_key "meli_accounts", "users"
  add_foreign_key "meli_auth_tokens", "meli_accounts"
  add_foreign_key "meli_notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "shipments", "orders"
  add_foreign_key "subscribers", "products"
  add_foreign_key "tax_accounts", "users"
end
