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

ActiveRecord::Schema[7.0].define(version: 2025_05_26_191624) do
  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.string "bio"
    t.string "fb"
    t.string "ig"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_authors_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipe_categories", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_recipe_categories_on_category_id"
    t.index ["recipe_id"], name: "index_recipe_categories_on_recipe_id"
  end

  create_table "recipe_likes", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_likes_on_recipe_id"
    t.index ["user_id"], name: "index_recipe_likes_on_user_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "title"
    t.text "text"
    t.integer "difficulty"
    t.integer "preparation_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "author_id"
    t.index ["author_id"], name: "index_recipes_on_author_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authors", "users"
  add_foreign_key "recipe_categories", "categories"
  add_foreign_key "recipe_categories", "recipes"
  add_foreign_key "recipe_likes", "recipes"
  add_foreign_key "recipe_likes", "users"
  add_foreign_key "recipes", "authors"
end
