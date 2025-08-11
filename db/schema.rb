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

ActiveRecord::Schema[7.1].define(version: 2025_08_06_094951) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matchups", force: :cascade do |t|
    t.string "user_champion"
    t.string "user_role"
    t.json "ally_team"
    t.json "enemy_team"
    t.text "ai_response"
    t.string "riot_match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "runes"
    t.json "core_items"
    t.json "situational_items"
    t.text "playstyle_early"
    t.text "playstyle_midgame"
    t.text "playstyle_lategame"
    t.text "summary"
  end

end
