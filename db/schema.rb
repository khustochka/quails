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

ActiveRecord::Schema.define(version: 20170105030639) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "slug",        limit: 32,  null: false
    t.string "name",        limit: 255
    t.text   "description"
  end

  create_table "cards", force: :cascade do |t|
    t.date     "observ_date",                                         null: false
    t.integer  "locus_id",                                            null: false
    t.string   "biotope",          limit: 255
    t.string   "weather",          limit: 255
    t.string   "start_time",       limit: 5
    t.text     "notes",                        default: "",           null: false
    t.string   "observers",        limit: 255
    t.integer  "post_id"
    t.boolean  "autogenerated",                default: false,        null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "kml_url",          limit: 255, default: "",           null: false
    t.string   "effort_type",      limit: 255, default: "INCIDENTAL", null: false
    t.integer  "duration_minutes"
    t.float    "distance_kms"
    t.float    "area_acres"
    t.boolean  "resolved",                     default: false,        null: false
    t.string   "ebird_id"
    t.index ["locus_id"], name: "index_cards_on_locus_id", using: :btree
    t.index ["observ_date"], name: "index_cards_on_observ_date", using: :btree
    t.index ["post_id"], name: "index_cards_on_post_id", using: :btree
  end

  create_table "commenters", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.string   "name",       limit: 255
    t.string   "provider"
    t.text     "auth_hash"
    t.string   "uid"
    t.string   "url"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "post_id",                                  null: false
    t.integer  "parent_id",                                null: false
    t.string   "name",         limit: 255,                 null: false
    t.string   "url",          limit: 255
    t.text     "text",                                     null: false
    t.boolean  "approved",                                 null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "ip",           limit: 15
    t.boolean  "send_email",               default: false
    t.integer  "commenter_id"
    t.index ["post_id"], name: "index_comments_on_post_id", using: :btree
  end

  create_table "ebird_files", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "status",     limit: 255, default: "NEW", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ebird_submissions", force: :cascade do |t|
    t.integer "ebird_file_id", null: false
    t.integer "card_id",       null: false
  end

  create_table "ebird_taxa", force: :cascade do |t|
    t.string  "name_sci",            null: false
    t.string  "name_en",             null: false
    t.string  "name_ioc_en",         null: false
    t.string  "category",            null: false
    t.string  "ebird_code",          null: false
    t.string  "order"
    t.string  "family"
    t.string  "ebird_order_num_str"
    t.integer "index_num",           null: false
    t.integer "parent_id"
  end

  create_table "legacy_species", force: :cascade do |t|
    t.string  "code",       limit: 6
    t.string  "name_sci",   limit: 255,                 null: false
    t.string  "authority",  limit: 255
    t.string  "name_en",    limit: 255,                 null: false
    t.string  "name_ru",    limit: 255
    t.string  "name_uk",    limit: 255
    t.integer "index_num",                              null: false
    t.string  "order",      limit: 255
    t.string  "family",     limit: 255,                 null: false
    t.string  "avibase_id", limit: 16
    t.string  "protonym",   limit: 255
    t.string  "name_fr",    limit: 255
    t.boolean "reviewed",               default: false, null: false
    t.text    "wikidata"
    t.integer "species_id"
    t.index ["code"], name: "index_legacy_species_on_code", unique: true, using: :btree
    t.index ["index_num"], name: "index_legacy_species_on_index_num", using: :btree
    t.index ["name_sci"], name: "index_legacy_species_on_name_sci", unique: true, using: :btree
  end

  create_table "legacy_taxa", force: :cascade do |t|
    t.integer "book_id",                       null: false
    t.integer "legacy_species_id"
    t.string  "name_sci",          limit: 255, null: false
    t.string  "authority",         limit: 255, null: false
    t.string  "name_en",           limit: 255, null: false
    t.string  "name_ru",           limit: 255, null: false
    t.string  "name_uk",           limit: 255, null: false
    t.integer "index_num",                     null: false
    t.string  "order",             limit: 255, null: false
    t.string  "family",            limit: 255, null: false
    t.string  "avibase_id",        limit: 16
    t.index ["book_id", "index_num"], name: "index_legacy_taxa_on_book_id_and_index_num", using: :btree
    t.index ["book_id", "name_sci"], name: "index_legacy_taxa_on_book_id_and_name_sci", using: :btree
  end

  create_table "local_species", force: :cascade do |t|
    t.integer "locus_id",               null: false
    t.integer "species_id",             null: false
    t.string  "status",     limit: 255
    t.text    "notes_en"
    t.text    "notes_ru"
    t.text    "notes_uk"
    t.string  "reference",  limit: 255
    t.index ["locus_id"], name: "index_local_species_on_locus_id", using: :btree
    t.index ["species_id"], name: "index_local_species_on_species_id", using: :btree
  end

  create_table "loci", force: :cascade do |t|
    t.string  "slug",         limit: 32,                  null: false
    t.string  "name_en",      limit: 255
    t.string  "name_ru",      limit: 255
    t.string  "name_uk",      limit: 255
    t.float   "lat"
    t.float   "lon"
    t.integer "public_index"
    t.string  "iso_code",     limit: 3
    t.boolean "patch",                    default: false, null: false
    t.boolean "private_loc",              default: false, null: false
    t.string  "loc_type",     limit: 255
    t.string  "name_format",  limit: 255, default: "",    null: false
    t.string  "ancestry",     limit: 255
    t.index ["ancestry"], name: "index_loci_on_ancestry", using: :btree
    t.index ["slug"], name: "index_loci_on_slug", unique: true, using: :btree
  end

  create_table "media", force: :cascade do |t|
    t.string   "slug",              limit: 64,                    null: false
    t.string   "media_type",        limit: 5,                     null: false
    t.string   "title"
    t.string   "external_id"
    t.text     "description"
    t.integer  "spot_id"
    t.integer  "index_num",                    default: 1000
    t.boolean  "has_old_thumbnail",            default: false
    t.text     "assets_cache",                 default: ""
    t.string   "status",            limit: 16, default: "PUBLIC"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_media_on_slug", unique: true, using: :btree
  end

  create_table "media_observations", id: false, force: :cascade do |t|
    t.integer "media_id",       null: false
    t.integer "observation_id", null: false
    t.index ["media_id"], name: "index_media_observations_on_media_id", using: :btree
    t.index ["observation_id"], name: "index_media_observations_on_observation_id", using: :btree
  end

  create_table "observations", force: :cascade do |t|
    t.integer "legacy_species_id"
    t.string  "quantity",          limit: 255
    t.string  "private_notes",     limit: 255, default: "",    null: false
    t.string  "notes",                         default: "",    null: false
    t.integer "post_id"
    t.boolean "voice",                         default: false, null: false
    t.integer "card_id"
    t.integer "patch_id"
    t.string  "place",             limit: 255, default: "",    null: false
    t.integer "taxon_id"
    t.index ["card_id"], name: "index_observations_on_card_id", using: :btree
    t.index ["legacy_species_id"], name: "index_observations_on_legacy_species_id", using: :btree
    t.index ["post_id"], name: "index_observations_on_post_id", using: :btree
    t.index ["taxon_id"], name: "index_observations_on_taxon_id", using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.string   "slug",         limit: 64
    t.string   "title",        limit: 255, null: false
    t.text     "text",                     null: false
    t.string   "topic",        limit: 4
    t.string   "status",       limit: 4
    t.datetime "face_date",                null: false
    t.datetime "updated_at",               null: false
    t.datetime "commented_at"
    t.text     "lj_data"
    t.index ["face_date"], name: "index_posts_on_face_date", using: :btree
    t.index ["slug"], name: "index_posts_on_slug", unique: true, using: :btree
  end

  create_table "settings", id: false, force: :cascade do |t|
    t.string "key",   limit: 255, null: false
    t.string "value", limit: 255, null: false
  end

  create_table "species", force: :cascade do |t|
    t.string  "name_sci",                              null: false
    t.string  "name_en",                               null: false
    t.string  "name_ru"
    t.string  "name_uk"
    t.string  "name_fr"
    t.string  "code",        limit: 6
    t.string  "legacy_code", limit: 6
    t.string  "order",                                 null: false
    t.string  "family",                                null: false
    t.string  "authority"
    t.boolean "reviewed",              default: false, null: false
    t.integer "index_num",                             null: false
  end

  create_table "species_images", force: :cascade do |t|
    t.integer "species_id", null: false
    t.integer "image_id",   null: false
    t.index ["species_id"], name: "index_species_images_on_species_id", unique: true, using: :btree
  end

  create_table "spots", force: :cascade do |t|
    t.integer "observation_id"
    t.float   "lat"
    t.float   "lng"
    t.integer "zoom"
    t.integer "exactness"
    t.boolean "public"
    t.string  "memo",           limit: 255
    t.index ["observation_id"], name: "index_spots_on_observation_id", using: :btree
  end

  create_table "taxa", force: :cascade do |t|
    t.string  "name_sci",       null: false
    t.string  "name_en",        null: false
    t.string  "name_ru"
    t.string  "category",       null: false
    t.string  "order"
    t.string  "family"
    t.integer "index_num",      null: false
    t.string  "ebird_code",     null: false
    t.integer "parent_id"
    t.integer "species_id"
    t.integer "ebird_taxon_id"
  end

  create_table "url_synonyms", force: :cascade do |t|
    t.string  "name_sci"
    t.integer "species_id"
  end

end
