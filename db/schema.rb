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

ActiveRecord::Schema.define(version: 2019_12_12_183114) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_acts", force: :cascade do |t|
    t.integer "event_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.datetime "start"
    t.datetime "end"
    t.string "address"
    t.string "name"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.string "background_url"
    t.string "text_color"
    t.string "title_color"
    t.string "screenshot_uuid"
    t.boolean "live", default: false
    t.string "url_id"
    t.string "eventbrite_url"
  end

  create_table "flyers", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.integer "event_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "songs", force: :cascade do |t|
    t.string "md5"
    t.string "title"
    t.integer "artist_id"
    t.integer "album_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "video_flyers", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.integer "event_id"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "format_string"
  end

  create_table "video_formats", force: :cascade do |t|
    t.integer "width"
    t.integer "height"
    t.string "name"
    t.boolean "title"
    t.boolean "line_up"
    t.boolean "address"
    t.boolean "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
