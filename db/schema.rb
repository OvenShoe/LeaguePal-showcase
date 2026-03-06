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

ActiveRecord::Schema[8.1].define(version: 2026_03_04_224734) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "competition_admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_competition_admins_on_user_id"
  end

  create_table "competitions", force: :cascade do |t|
    t.bigint "competition_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "end_date"
    t.string "name"
    t.integer "sport", default: 0, null: false
    t.datetime "start_date"
    t.datetime "updated_at", null: false
    t.index ["competition_admin_id"], name: "index_competitions_on_competition_admin_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "round_id", null: false
    t.bigint "team_1_id"
    t.bigint "team_2_id"
    t.datetime "updated_at", null: false
    t.index ["round_id"], name: "index_games_on_round_id"
    t.index ["team_1_id"], name: "index_games_on_team_1_id"
    t.index ["team_2_id"], name: "index_games_on_team_2_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "competition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competition_id"], name: "index_rounds_on_competition_id"
  end

  create_table "stats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.string "label"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "value"
    t.index ["game_id"], name: "index_stats_on_game_id"
    t.index ["user_id"], name: "index_stats_on_user_id"
  end

  create_table "team_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "invitee_email", null: false
    t.bigint "inviter_id", null: false
    t.bigint "team_id", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_email"], name: "index_team_invitations_on_invitee_email"
    t.index ["inviter_id"], name: "index_team_invitations_on_inviter_id"
    t.index ["team_id"], name: "index_team_invitations_on_team_id"
    t.index ["token_digest"], name: "index_team_invitations_on_token_digest", unique: true
  end

  create_table "team_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "role", default: 0, null: false
    t.bigint "team_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "competition_id", null: false
    t.integer "competition_points"
    t.datetime "created_at", null: false
    t.integer "draws"
    t.string "form", default: [], array: true
    t.integer "games_played"
    t.integer "losses"
    t.string "name"
    t.integer "points_against"
    t.integer "points_for"
    t.datetime "updated_at", null: false
    t.integer "wins"
    t.index ["competition_id"], name: "index_teams_on_competition_id"
  end

  create_table "trophies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.bigint "team_member_id", null: false
    t.integer "trophy_type"
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_trophies_on_game_id"
    t.index ["team_member_id"], name: "index_trophies_on_team_member_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.string "team_position"
    t.string "thumbnail"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "competition_admins", "users"
  add_foreign_key "competitions", "competition_admins"
  add_foreign_key "games", "rounds"
  add_foreign_key "games", "teams", column: "team_1_id"
  add_foreign_key "games", "teams", column: "team_2_id"
  add_foreign_key "rounds", "competitions"
  add_foreign_key "stats", "games"
  add_foreign_key "stats", "users"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_invitations", "users", column: "inviter_id"
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "competitions"
  add_foreign_key "trophies", "games"
  add_foreign_key "trophies", "team_members"
end
