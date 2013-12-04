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

ActiveRecord::Schema.define(version: 20131204090740) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: true do |t|
    t.string "slug",        limit: 32, null: false
    t.string "name"
    t.text   "description"
  end

  create_table "cards", force: true do |t|
    t.date     "observ_date",                   null: false
    t.integer  "locus_id",                      null: false
    t.string   "biotope"
    t.string   "weather"
    t.string   "time"
    t.string   "route"
    t.text     "notes",         default: "",    null: false
    t.string   "observers"
    t.integer  "post_id"
    t.boolean  "autogenerated", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "kml_url",       default: "",    null: false
  end

  create_table "commenters", force: true do |t|
    t.string  "email"
    t.string  "name"
    t.boolean "is_admin", default: false
  end

  create_table "comments", force: true do |t|
    t.integer  "post_id",                               null: false
    t.integer  "parent_id",                             null: false
    t.string   "name",                                  null: false
    t.string   "url"
    t.text     "text",                                  null: false
    t.boolean  "approved",                              null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "ip",         limit: 15
    t.boolean  "send_email",            default: false
  end

  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "slug",              limit: 64,                   null: false
    t.string   "title"
    t.text     "description"
    t.integer  "index_num",                    default: 1000,    null: false
    t.datetime "created_at",                                     null: false
    t.integer  "spot_id"
    t.string   "flickr_id",         limit: 64
    t.boolean  "has_old_thumbnail",            default: false,   null: false
    t.datetime "updated_at",                                     null: false
    t.text     "assets_cache",                 default: "",      null: false
    t.string   "status",            limit: 5,  default: "DEFLT", null: false
    t.integer  "parent_id"
  end

  add_index "images", ["index_num"], name: "index_images_on_index_num", using: :btree
  add_index "images", ["slug"], name: "index_images_on_slug", unique: true, using: :btree

  create_table "images_observations", id: false, force: true do |t|
    t.integer "image_id",       null: false
    t.integer "observation_id", null: false
  end

  add_index "images_observations", ["image_id"], name: "index_images_observations_on_image_id", using: :btree
  add_index "images_observations", ["observation_id"], name: "index_images_observations_on_observation_id", using: :btree

  create_table "local_species", force: true do |t|
    t.integer "locus_id",   null: false
    t.integer "species_id", null: false
    t.string  "status"
    t.text    "notes_en"
    t.text    "notes_ru"
    t.text    "notes_uk"
    t.string  "reference"
  end

  add_index "local_species", ["locus_id"], name: "index_local_species_on_locus_id", using: :btree
  add_index "local_species", ["species_id"], name: "index_local_species_on_species_id", using: :btree

  create_table "loci", force: true do |t|
    t.string  "slug",         limit: 32, null: false
    t.integer "parent_id"
    t.string  "name_en"
    t.string  "name_ru"
    t.string  "name_uk"
    t.float   "lat"
    t.float   "lon"
    t.integer "public_index"
  end

  add_index "loci", ["parent_id"], name: "index_loci_on_parent_id", using: :btree
  add_index "loci", ["slug"], name: "index_loci_on_slug", unique: true, using: :btree

  create_table "observations", force: true do |t|
    t.integer "species_id",                 null: false
    t.string  "quantity"
    t.string  "place"
    t.string  "notes"
    t.integer "post_id"
    t.boolean "voice",      default: false, null: false
    t.integer "card_id"
  end

  add_index "observations", ["post_id"], name: "index_observations_on_post_id", using: :btree
  add_index "observations", ["species_id"], name: "index_observations_on_species_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "slug",                       null: false
    t.string   "title",                      null: false
    t.text     "meta"
    t.text     "text"
    t.boolean  "public",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "likable",    default: false
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", unique: true, using: :btree

  create_table "posts", force: true do |t|
    t.string   "slug",         limit: 64
    t.string   "title",                   null: false
    t.text     "text",                    null: false
    t.string   "topic",        limit: 4
    t.string   "status",       limit: 4
    t.integer  "lj_post_id"
    t.integer  "lj_url_id"
    t.datetime "face_date",               null: false
    t.datetime "updated_at",              null: false
    t.datetime "commented_at"
  end

  add_index "posts", ["face_date"], name: "index_posts_on_face_date", using: :btree
  add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true, using: :btree

  create_table "settings", id: false, force: true do |t|
    t.string "key",   null: false
    t.string "value", null: false
  end

  create_table "species", force: true do |t|
    t.string  "code",       limit: 6
    t.string  "name_sci",                              null: false
    t.string  "authority"
    t.string  "name_en",                               null: false
    t.string  "name_ru"
    t.string  "name_uk"
    t.integer "index_num",                             null: false
    t.string  "order"
    t.string  "family",                                null: false
    t.string  "avibase_id", limit: 16
    t.string  "protonym"
    t.string  "name_fr"
    t.boolean "reviewed",              default: false, null: false
    t.text    "wikidata"
  end

  add_index "species", ["code"], name: "index_species_on_code", unique: true, using: :btree
  add_index "species", ["index_num"], name: "index_species_on_index_num", using: :btree
  add_index "species", ["name_sci"], name: "index_species_on_name_sci", unique: true, using: :btree

  create_table "species_images", force: true do |t|
    t.integer "species_id", null: false
    t.integer "image_id",   null: false
  end

  add_index "species_images", ["species_id"], name: "index_species_images_on_species_id", unique: true, using: :btree

  create_table "spots", force: true do |t|
    t.integer "observation_id"
    t.float   "lat"
    t.float   "lng"
    t.integer "zoom"
    t.integer "exactness"
    t.boolean "public"
    t.string  "memo"
  end

  add_index "spots", ["observation_id"], name: "index_spots_on_observation_id", using: :btree

  create_table "taxa", force: true do |t|
    t.integer "book_id",               null: false
    t.integer "species_id"
    t.string  "name_sci",              null: false
    t.string  "authority",             null: false
    t.string  "name_en",               null: false
    t.string  "name_ru",               null: false
    t.string  "name_uk",               null: false
    t.integer "index_num",             null: false
    t.string  "order",                 null: false
    t.string  "family",                null: false
    t.string  "avibase_id", limit: 16
  end

  add_index "taxa", ["book_id", "index_num"], name: "index_taxa_on_book_id_and_index_num", using: :btree
  add_index "taxa", ["book_id", "name_sci"], name: "index_taxa_on_book_id_and_name_sci", using: :btree

end
