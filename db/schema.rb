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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130523093951) do

  create_table "books", :force => true do |t|
    t.string "slug",        :limit => 32, :null => false
    t.string "name"
    t.text   "description"
  end

  create_table "comments", :force => true do |t|
    t.integer  "post_id",                  :null => false
    t.integer  "parent_id",                :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "name",                     :null => false
    t.string   "email"
    t.string   "url"
    t.text     "text",                     :null => false
    t.boolean  "approved",                 :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "ip",         :limit => 15
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "images", :force => true do |t|
    t.string   "slug",              :limit => 64,                    :null => false
    t.string   "title"
    t.text     "description"
    t.integer  "index_num",                       :default => 1000,  :null => false
    t.datetime "created_at",                                         :null => false
    t.integer  "spot_id"
    t.string   "flickr_id",         :limit => 64
    t.text     "flickr_data"
    t.string   "flickr_size",       :limit => 1
    t.boolean  "has_old_thumbnail",               :default => false, :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "images", ["index_num"], :name => "index_images_on_index_num"
  add_index "images", ["slug"], :name => "index_images_on_slug", :unique => true

  create_table "images_observations", :id => false, :force => true do |t|
    t.integer "image_id",       :null => false
    t.integer "observation_id", :null => false
  end

  add_index "images_observations", ["image_id"], :name => "index_images_observations_on_image_id"
  add_index "images_observations", ["observation_id"], :name => "index_images_observations_on_observation_id"

  create_table "local_species", :force => true do |t|
    t.integer "locus_id",   :null => false
    t.integer "species_id", :null => false
    t.string  "status"
    t.text    "notes_en"
    t.text    "notes_ru"
    t.text    "notes_uk"
    t.string  "reference"
  end

  add_index "local_species", ["locus_id"], :name => "index_local_species_on_locus_id"
  add_index "local_species", ["species_id"], :name => "index_local_species_on_species_id"

  create_table "loci", :force => true do |t|
    t.string  "slug",         :limit => 32, :null => false
    t.integer "parent_id"
    t.string  "name_en"
    t.string  "name_ru"
    t.string  "name_uk"
    t.float   "lat"
    t.float   "lon"
    t.integer "public_index"
  end

  add_index "loci", ["parent_id"], :name => "index_loci_on_parent_id"
  add_index "loci", ["slug"], :name => "index_loci_on_slug", :unique => true

  create_table "observations", :force => true do |t|
    t.integer "species_id",                    :null => false
    t.string  "quantity"
    t.string  "place"
    t.string  "notes"
    t.boolean "mine",       :default => true,  :null => false
    t.integer "post_id"
    t.boolean "voice",      :default => false, :null => false
    t.integer "card_id"
  end

  add_index "observations", ["post_id"], :name => "index_observations_on_post_id"
  add_index "observations", ["species_id"], :name => "index_observations_on_species_id"

  create_table "posts", :force => true do |t|
    t.string   "slug",         :limit => 64
    t.string   "title",                      :null => false
    t.text     "text",                       :null => false
    t.string   "topic",        :limit => 4
    t.string   "status",       :limit => 4
    t.integer  "lj_post_id"
    t.integer  "lj_url_id"
    t.datetime "face_date",                  :null => false
    t.datetime "updated_at",                 :null => false
    t.datetime "commented_at"
  end

  add_index "posts", ["face_date"], :name => "index_posts_on_face_date"
  add_index "posts", ["slug"], :name => "index_posts_on_slug", :unique => true

  create_table "settings", :id => false, :force => true do |t|
    t.string "key",   :null => false
    t.string "value", :null => false
  end

  create_table "species", :force => true do |t|
    t.string  "code",       :limit => 6
    t.string  "name_sci",                                    :null => false
    t.string  "authority"
    t.string  "name_en",                                     :null => false
    t.string  "name_ru"
    t.string  "name_uk"
    t.integer "index_num",                                   :null => false
    t.string  "order"
    t.string  "family",                                      :null => false
    t.string  "avibase_id", :limit => 16
    t.string  "protonym"
    t.string  "name_fr"
    t.integer "image_id"
    t.boolean "reviewed",                 :default => false, :null => false
    t.text    "wikidata"
  end

  add_index "species", ["code"], :name => "index_species_on_code", :unique => true
  add_index "species", ["index_num"], :name => "index_species_on_index_num"
  add_index "species", ["name_sci"], :name => "index_species_on_name_sci", :unique => true

  create_table "spots", :force => true do |t|
    t.integer "observation_id"
    t.float   "lat"
    t.float   "lng"
    t.integer "zoom"
    t.integer "exactness"
    t.boolean "public"
    t.string  "memo"
  end

  add_index "spots", ["observation_id"], :name => "index_spots_on_observation_id"

  create_table "taxa", :force => true do |t|
    t.integer "book_id",                  :null => false
    t.integer "species_id"
    t.string  "name_sci",                 :null => false
    t.string  "authority",                :null => false
    t.string  "name_en",                  :null => false
    t.string  "name_ru",                  :null => false
    t.string  "name_uk",                  :null => false
    t.integer "index_num",                :null => false
    t.string  "order",                    :null => false
    t.string  "family",                   :null => false
    t.string  "avibase_id", :limit => 16
  end

  add_index "taxa", ["book_id", "index_num"], :name => "index_taxa_on_book_id_and_index_num"
  add_index "taxa", ["book_id", "name_sci"], :name => "index_taxa_on_book_id_and_name_sci"

end
