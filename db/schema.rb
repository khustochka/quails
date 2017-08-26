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

ActiveRecord::Schema.define(version: 20170826160039) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 32, null: false
    t.string "name", limit: 255
    t.text "description"
  end

  create_table "cards", id: :serial, force: :cascade do |t|
    t.date "observ_date", null: false
    t.integer "locus_id", null: false
    t.string "biotope", limit: 255
    t.string "weather", limit: 255
    t.string "start_time", limit: 5
    t.text "notes", default: "", null: false
    t.string "observers", limit: 255
    t.integer "post_id"
    t.boolean "autogenerated", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kml_url", limit: 255, default: "", null: false
    t.string "effort_type", limit: 255, default: "INCIDENTAL", null: false
    t.integer "duration_minutes"
    t.float "distance_kms"
    t.float "area_acres"
    t.boolean "resolved", default: false, null: false
    t.string "ebird_id"
    t.index ["locus_id"], name: "index_cards_on_locus_id"
    t.index ["observ_date"], name: "index_cards_on_observ_date"
    t.index ["post_id"], name: "index_cards_on_post_id"
  end

  create_table "commenters", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "name", limit: 255
    t.boolean "is_admin", default: false
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "parent_id", null: false
    t.string "name", limit: 255, null: false
    t.string "url", limit: 255
    t.text "text", null: false
    t.boolean "approved", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip", limit: 15
    t.boolean "send_email", default: false
    t.integer "commenter_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "ebird_files", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "status", limit: 255, default: "NEW", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ebird_submissions", id: :serial, force: :cascade do |t|
    t.integer "ebird_file_id", null: false
    t.integer "card_id", null: false
  end

  create_table "ebird_taxa", id: :serial, force: :cascade do |t|
    t.string "name_sci", null: false
    t.string "name_en", null: false
    t.string "name_ioc_en"
    t.string "category", null: false
    t.string "ebird_code", null: false
    t.string "order"
    t.string "family"
    t.string "ebird_order_num_str"
    t.integer "index_num", null: false
    t.integer "parent_id"
    t.integer "ebird_version", limit: 2, null: false
    t.index ["ebird_code"], name: "index_ebird_taxa_on_ebird_code"
    t.index ["index_num"], name: "index_ebird_taxa_on_index_num"
    t.index ["parent_id"], name: "index_ebird_taxa_on_parent_id"
  end

  create_table "legacy_species", id: :serial, force: :cascade do |t|
    t.string "code", limit: 6
    t.string "name_sci", limit: 255, null: false
    t.string "authority", limit: 255
    t.string "name_en", limit: 255, null: false
    t.string "name_ru", limit: 255
    t.string "name_uk", limit: 255
    t.integer "index_num", null: false
    t.string "order", limit: 255
    t.string "family", limit: 255, null: false
    t.string "avibase_id", limit: 16
    t.string "protonym", limit: 255
    t.string "name_fr", limit: 255
    t.boolean "reviewed", default: false, null: false
    t.text "wikidata"
    t.integer "species_id"
    t.index ["code"], name: "index_legacy_species_on_code", unique: true
    t.index ["index_num"], name: "index_legacy_species_on_index_num"
    t.index ["name_sci"], name: "index_legacy_species_on_name_sci", unique: true
  end

  create_table "legacy_taxa", id: :serial, force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "legacy_species_id"
    t.string "name_sci", limit: 255, null: false
    t.string "authority", limit: 255, null: false
    t.string "name_en", limit: 255, null: false
    t.string "name_ru", limit: 255, null: false
    t.string "name_uk", limit: 255, null: false
    t.integer "index_num", null: false
    t.string "order", limit: 255, null: false
    t.string "family", limit: 255, null: false
    t.string "avibase_id", limit: 16
    t.index ["book_id", "index_num"], name: "index_legacy_taxa_on_book_id_and_index_num"
    t.index ["book_id", "name_sci"], name: "index_legacy_taxa_on_book_id_and_name_sci"
  end

  create_table "local_species", id: :serial, force: :cascade do |t|
    t.integer "locus_id", null: false
    t.integer "species_id", null: false
    t.string "status", limit: 255
    t.text "notes_en"
    t.text "notes_ru"
    t.text "notes_uk"
    t.string "reference", limit: 255
    t.index ["locus_id"], name: "index_local_species_on_locus_id"
    t.index ["species_id"], name: "index_local_species_on_species_id"
  end

  create_table "loci", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 32, null: false
    t.string "name_en", limit: 255
    t.string "name_ru", limit: 255
    t.string "name_uk", limit: 255
    t.float "lat"
    t.float "lon"
    t.integer "public_index"
    t.string "iso_code", limit: 3
    t.boolean "patch", default: false, null: false
    t.boolean "private_loc", default: false, null: false
    t.string "loc_type", limit: 255
    t.string "name_format", limit: 255, default: "", null: false
    t.string "ancestry", limit: 255
    t.index ["ancestry"], name: "index_loci_on_ancestry"
    t.index ["slug"], name: "index_loci_on_slug", unique: true
  end

  create_table "media", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 64, null: false
    t.string "media_type", limit: 5, null: false
    t.string "title"
    t.string "external_id"
    t.text "description"
    t.integer "spot_id"
    t.integer "index_num", default: 1000
    t.boolean "has_old_thumbnail", default: false
    t.text "assets_cache", default: ""
    t.string "status", limit: 16, default: "PUBLIC"
    t.integer "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], name: "index_media_on_slug", unique: true
  end

  create_table "media_observations", id: false, force: :cascade do |t|
    t.integer "media_id", null: false
    t.integer "observation_id", null: false
    t.index ["media_id"], name: "index_media_observations_on_media_id"
    t.index ["observation_id"], name: "index_media_observations_on_observation_id"
  end

  create_table "observations", id: :serial, force: :cascade do |t|
    t.string "quantity", limit: 255
    t.string "private_notes", limit: 255, default: "", null: false
    t.string "notes", default: "", null: false
    t.integer "post_id"
    t.boolean "voice", default: false, null: false
    t.integer "card_id"
    t.integer "patch_id"
    t.string "place", limit: 255, default: "", null: false
    t.integer "taxon_id"
    t.index ["card_id"], name: "index_observations_on_card_id"
    t.index ["post_id"], name: "index_observations_on_post_id"
    t.index ["taxon_id"], name: "index_observations_on_taxon_id"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 64
    t.string "title", limit: 255, null: false
    t.text "text", null: false
    t.string "topic", limit: 4
    t.string "status", limit: 4
    t.datetime "face_date", null: false
    t.datetime "updated_at", null: false
    t.datetime "commented_at"
    t.text "lj_data"
    t.index ["face_date"], name: "index_posts_on_face_date"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "settings", id: false, force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "value", limit: 255, null: false
  end

  create_table "species", id: :serial, force: :cascade do |t|
    t.string "name_sci", null: false
    t.string "name_en", null: false
    t.string "name_ru"
    t.string "name_uk"
    t.string "name_fr"
    t.string "code", limit: 6
    t.string "legacy_code", limit: 6
    t.string "order", null: false
    t.string "family", null: false
    t.string "authority"
    t.boolean "reviewed", default: false, null: false
    t.integer "index_num", null: false
    t.index ["index_num"], name: "index_species_on_index_num"
    t.index ["name_sci"], name: "index_species_on_name_sci"
  end

  create_table "species_images", id: :serial, force: :cascade do |t|
    t.integer "species_id", null: false
    t.integer "image_id", null: false
    t.index ["image_id"], name: "index_species_images_on_image_id"
    t.index ["species_id"], name: "index_species_images_on_species_id", unique: true
  end

  create_table "species_splits", force: :cascade do |t|
    t.bigint "superspecies_id"
    t.bigint "subspecies_id"
    t.index ["subspecies_id"], name: "index_species_splits_on_subspecies_id"
    t.index ["superspecies_id"], name: "index_species_splits_on_superspecies_id"
  end

  create_table "spots", id: :serial, force: :cascade do |t|
    t.integer "observation_id"
    t.float "lat"
    t.float "lng"
    t.integer "zoom"
    t.integer "exactness"
    t.boolean "public"
    t.string "memo", limit: 255
    t.index ["observation_id"], name: "index_spots_on_observation_id"
  end

  create_table "taxa", id: :serial, force: :cascade do |t|
    t.string "name_sci", null: false
    t.string "name_en", null: false
    t.string "name_ru"
    t.string "category", null: false
    t.string "order"
    t.string "family"
    t.integer "index_num", null: false
    t.string "ebird_code", null: false
    t.integer "parent_id"
    t.integer "species_id"
    t.integer "ebird_taxon_id"
    t.index ["ebird_code"], name: "index_taxa_on_ebird_code"
    t.index ["index_num"], name: "index_taxa_on_index_num"
    t.index ["parent_id"], name: "index_taxa_on_parent_id"
    t.index ["species_id"], name: "index_taxa_on_species_id"
  end

  create_table "url_synonyms", id: :serial, force: :cascade do |t|
    t.string "name_sci"
    t.integer "species_id"
    t.string "reason"
    t.index ["name_sci"], name: "index_url_synonyms_on_name_sci"
  end

end
