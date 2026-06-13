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

ActiveRecord::Schema[8.1].define(version: 2026_06_13_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ai_integrations", force: :cascade do |t|
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.boolean "enabled"
    t.string "endpoint_url"
    t.string "harness_type"
    t.datetime "last_health_check"
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.string "provider"
    t.string "status", default: "unknown"
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_ai_integrations_on_enabled"
    t.index ["harness_type"], name: "index_ai_integrations_on_harness_type"
    t.index ["project_id", "harness_type"], name: "index_ai_integrations_on_project_id_and_harness_type"
    t.index ["project_id"], name: "index_ai_integrations_on_project_id"
    t.index ["provider"], name: "index_ai_integrations_on_provider"
    t.index ["status"], name: "index_ai_integrations_on_status"
  end

  create_table "assets", force: :cascade do |t|
    t.string "asset_type"
    t.datetime "created_at", null: false
    t.string "file_path"
    t.jsonb "metadata"
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_type"], name: "index_assets_on_asset_type"
    t.index ["project_id"], name: "index_assets_on_project_id"
  end

  create_table "journal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "entry_date", default: -> { "CURRENT_DATE" }
    t.bigint "project_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_date"], name: "index_journal_entries_on_entry_date"
    t.index ["project_id"], name: "index_journal_entries_on_project_id"
  end

  create_table "project_types", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_project_types_on_name", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.jsonb "config"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.bigint "project_type_id", null: false
    t.string "repo_url"
    t.string "status", default: "planning"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "website_url"
    t.index ["project_type_id"], name: "index_projects_on_project_type_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id", "tag_id"], name: "index_taggings_uniqueness", unique: true
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.jsonb "colors"
    t.datetime "created_at", null: false
    t.boolean "is_system"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_themes_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.string "password_digest"
    t.string "theme_name"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_integrations", "projects"
  add_foreign_key "assets", "projects"
  add_foreign_key "journal_entries", "projects"
  add_foreign_key "projects", "project_types"
  add_foreign_key "projects", "users"
  add_foreign_key "taggings", "tags"
end
