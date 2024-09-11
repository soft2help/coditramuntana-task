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

ActiveRecord::Schema[7.1].define(version: 2024_09_11_162512) do
  create_table "api_keys", force: :cascade do |t|
    t.string "common_token_prefix"
    t.string "encrypted_random_token_prefix"
    t.string "token_digest", null: false
    t.string "name"
    t.datetime "revoked_at"
    t.datetime "expires_in"
    t.string "bearer_type"
    t.integer "bearer_id"
    t.text "access_control_rules", default: "--- {}\n"
    t.text "permissions", default: "--- {}\n"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bearer_type", "bearer_id"], name: "index_api_keys_on_bearer"
    t.index ["expires_in"], name: "expires_in_index"
    t.index ["name"], name: "name_index"
    t.index ["revoked_at"], name: "revoked_at_index"
    t.index ["token_digest"], name: "token_digest_index", unique: true
  end

  create_table "artists", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_artists_on_name", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_authors_on_name", unique: true
  end

  create_table "lps", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_lps_on_artist_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.string "group", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group", "key"], name: "group_key_index", unique: true
    t.index ["group"], name: "group_index"
    t.index ["key"], name: "key_index", unique: true
  end

  create_table "song_authors", force: :cascade do |t|
    t.integer "song_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_song_authors_on_author_id"
    t.index ["song_id"], name: "index_song_authors_on_song_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.integer "lp_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lp_id"], name: "index_songs_on_lp_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.text "roles", default: "--- []\n"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "email_index", unique: true
  end

  add_foreign_key "lps", "artists", on_delete: :cascade
  add_foreign_key "song_authors", "authors"
  add_foreign_key "song_authors", "songs"
  add_foreign_key "songs", "lps"
  add_foreign_key "songs", "lps", on_delete: :nullify
end
