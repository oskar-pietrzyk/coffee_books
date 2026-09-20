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

ActiveRecord::Schema[8.1].define(version: 2026_09_20_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "author", null: false
    t.string "availability_status", default: "available", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 6, null: false
    t.index ["availability_status"], name: "index_books_on_availability_status"
    t.index ["created_at", "id"], name: "index_books_on_created_at_and_id", order: :desc
    t.index ["uuid"], name: "index_books_on_uuid", unique: true
  end

  create_table "readers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", limit: 6, null: false
    t.index ["email"], name: "index_readers_on_email", unique: true
    t.index ["uuid"], name: "index_readers_on_uuid", unique: true
  end

  create_table "rentals", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "borrowed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "due_reminder_sent_at"
    t.date "duration_date", null: false
    t.string "reading_status", default: "borrowed", null: false
    t.datetime "reminder_sent_at"
    t.datetime "returned_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id", "reading_status"], name: "index_rentals_on_book_id_and_reading_status"
    t.index ["book_id"], name: "index_rentals_on_book_id"
    t.index ["book_id"], name: "index_rentals_on_book_id_active", unique: true, where: "((reading_status)::text = 'borrowed'::text)"
    t.index ["reading_status", "duration_date"], name: "index_rentals_on_reading_status_and_duration_date"
    t.index ["user_id", "reading_status"], name: "index_rentals_on_user_id_and_reading_status"
    t.index ["user_id"], name: "index_rentals_on_user_id"
  end

  add_foreign_key "rentals", "books"
  add_foreign_key "rentals", "readers", column: "user_id"
end
