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

ActiveRecord::Schema[7.1].define(version: 2024_05_23_013956) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "kml_url", limit: 255, default: "", null: false
    t.string "effort_type", limit: 255, default: "INCIDENTAL", null: false
    t.integer "duration_minutes"
    t.float "distance_kms"
    t.float "area_acres"
    t.boolean "resolved", default: false, null: false
    t.string "ebird_id"
    t.boolean "motorless", default: false, null: false
    t.index ["ebird_id"], name: "index_cards_on_ebird_id", unique: true, where: "(ebird_id IS NOT NULL)"
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
    t.integer "parent_id"
    t.string "name", limit: 255, null: false
    t.string "url", limit: 255
    t.text "body", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "ip", limit: 45
    t.boolean "send_email", default: false
    t.integer "commenter_id"
    t.string "unsubscribe_token", limit: 25
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "corrections", force: :cascade do |t|
    t.string "model_classname", null: false
    t.string "query", null: false
    t.string "sort_column", default: "created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ebird_files", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "status", limit: 255, default: "NEW", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "ebird_locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "country_state"
    t.string "county"
    t.float "latitude"
    t.float "longtitude"
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
    t.bigint "taxon_id"
    t.string "taxon_concept_id"
    t.index ["ebird_code"], name: "index_ebird_taxa_on_ebird_code"
    t.index ["index_num"], name: "index_ebird_taxa_on_index_num"
    t.index ["parent_id"], name: "index_ebird_taxa_on_parent_id"
    t.index ["taxon_id"], name: "index_ebird_taxa_on_taxon_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "ioc_taxa", force: :cascade do |t|
    t.string "rank", null: false
    t.boolean "extinct", default: false, null: false
    t.string "name_en"
    t.string "name_sci", null: false
    t.string "authority"
    t.string "breeding_range"
    t.bigint "ioc_species_id"
    t.integer "index_num"
    t.string "version", null: false
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
    t.boolean "private_loc", default: false, null: false
    t.string "loc_type", limit: 255
    t.string "ancestry", limit: 255
    t.boolean "five_mile_radius", default: false, null: false
    t.integer "ebird_location_id"
    t.bigint "cached_parent_id"
    t.bigint "cached_city_id"
    t.bigint "cached_subdivision_id"
    t.bigint "cached_country_id"
    t.boolean "patch", default: false, null: false
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
    t.text "assets_cache", default: ""
    t.string "status", limit: 16, default: "PUBLIC"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "multi_species", default: false
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
    t.integer "taxon_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "ebird_obs_id"
    t.index ["card_id"], name: "index_observations_on_card_id"
    t.index ["post_id"], name: "index_observations_on_post_id"
    t.index ["taxon_id"], name: "index_observations_on_taxon_id"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 64
    t.string "title", limit: 255, null: false
    t.text "body", null: false
    t.string "topic", limit: 4
    t.string "status", limit: 4
    t.datetime "face_date", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "commented_at", precision: nil
    t.text "lj_data"
    t.string "cover_image_slug"
    t.boolean "publish_to_facebook", default: false, null: false
    t.string "lang", limit: 2, null: false
    t.index ["face_date"], name: "index_posts_on_face_date"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "value", limit: 255, null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "species", id: :serial, force: :cascade do |t|
    t.string "name_sci", null: false, collation: "C"
    t.string "name_en", null: false
    t.string "name_ru"
    t.string "name_uk"
    t.string "name_fr"
    t.string "code", limit: 6
    t.string "legacy_code", limit: 6
    t.string "order", null: false
    t.string "family", null: false
    t.string "authority"
    t.integer "index_num", null: false
    t.boolean "name_en_overwritten", default: false, null: false
    t.boolean "needs_review", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_species_on_code", unique: true
    t.index ["index_num"], name: "index_species_on_index_num"
    t.index ["legacy_code"], name: "index_species_on_legacy_code", unique: true
    t.index ["name_sci"], name: "index_species_on_name_sci", unique: true
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
    t.string "taxon_concept_id"
    t.index ["ebird_code"], name: "index_taxa_on_ebird_code"
    t.index ["index_num"], name: "index_taxa_on_index_num"
    t.index ["parent_id"], name: "index_taxa_on_parent_id"
    t.index ["species_id"], name: "index_taxa_on_species_id"
  end

  create_table "url_synonyms", id: :serial, force: :cascade do |t|
    t.string "name_sci", collation: "C"
    t.integer "species_id"
    t.string "reason"
    t.index ["name_sci"], name: "index_url_synonyms_on_name_sci", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cards", "loci", on_delete: :restrict
  add_foreign_key "cards", "posts", on_delete: :nullify
  add_foreign_key "comments", "commenters", on_delete: :restrict
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "posts", on_delete: :cascade
  add_foreign_key "ebird_submissions", "cards", on_delete: :cascade
  add_foreign_key "ebird_submissions", "ebird_files", on_delete: :cascade
  add_foreign_key "ebird_taxa", "ebird_taxa", column: "parent_id", on_delete: :restrict
  add_foreign_key "ebird_taxa", "taxa", on_delete: :nullify
  add_foreign_key "local_species", "loci", on_delete: :cascade
  add_foreign_key "local_species", "species", on_delete: :cascade
  add_foreign_key "media", "spots", on_delete: :nullify
  add_foreign_key "media_observations", "media", on_delete: :cascade
  add_foreign_key "media_observations", "observations", on_delete: :restrict
  add_foreign_key "observations", "cards", on_delete: :restrict
  add_foreign_key "observations", "posts", on_delete: :nullify
  add_foreign_key "observations", "taxa", on_delete: :restrict
  add_foreign_key "species_images", "media", column: "image_id", on_delete: :cascade
  add_foreign_key "species_images", "species", on_delete: :cascade
  add_foreign_key "species_splits", "species", column: "subspecies_id", on_delete: :cascade
  add_foreign_key "species_splits", "species", column: "superspecies_id", on_delete: :cascade
  add_foreign_key "spots", "observations", on_delete: :cascade
  add_foreign_key "taxa", "species", on_delete: :nullify
  add_foreign_key "taxa", "taxa", column: "parent_id", on_delete: :restrict
end
