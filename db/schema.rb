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

ActiveRecord::Schema.define(:version => 20110817074127) do

  create_table "images", :force => true do |t|
    t.string   "code",        :limit => 64, :null => false
    t.string   "title"
    t.text     "description"
    t.integer  "index_num"
    t.datetime "created_at"
  end

  add_index "images", ["code"], :name => "index_images_on_code"
  add_index "images", ["index_num"], :name => "index_images_on_index_num"

  create_table "images_observations", :id => false, :force => true do |t|
    t.integer "image_id",       :null => false
    t.integer "observation_id", :null => false
  end

  add_index "images_observations", ["image_id", "observation_id"], :name => "index_images_observations_on_image_id_and_observation_id", :unique => true

  create_table "loci", :force => true do |t|
    t.string  "code",      :limit => 32, :null => false
    t.integer "parent_id"
    t.string  "loc_type",  :limit => 8,  :null => false
    t.string  "name_en"
    t.string  "name_ru"
    t.string  "name_uk"
    t.float   "lat"
    t.float   "lon"
  end

  add_index "loci", ["code"], :name => "index_locus_on_code"
  add_index "loci", ["loc_type"], :name => "index_locus_on_loc_type"
  add_index "loci", ["parent_id"], :name => "index_locus_on_parent_id"

  create_table "observations", :force => true do |t|
    t.integer "species_id",                    :null => false
    t.integer "locus_id",                      :null => false
    t.date    "observ_date",                   :null => false
    t.string  "quantity"
    t.string  "biotope"
    t.string  "place"
    t.string  "notes"
    t.boolean "mine",        :default => true
    t.integer "post_id"
  end

  add_index "observations", ["locus_id"], :name => "index_observations_on_locus_id"
  add_index "observations", ["mine"], :name => "index_observations_on_mine"
  add_index "observations", ["observ_date"], :name => "index_observations_on_observ_date"
  add_index "observations", ["post_id"], :name => "index_observations_on_post_id"
  add_index "observations", ["species_id"], :name => "index_observations_on_species_id"

  create_table "posts", :force => true do |t|
    t.string   "code",       :limit => 64
    t.string   "title",                    :null => false
    t.text     "text",                     :null => false
    t.string   "topic",      :limit => 4
    t.string   "status",     :limit => 4
    t.integer  "lj_post_id"
    t.integer  "lj_url_id"
    t.datetime "face_date",                :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "posts", ["code"], :name => "index_posts_on_code"
  add_index "posts", ["face_date"], :name => "index_posts_on_created_at"
  add_index "posts", ["status"], :name => "index_posts_on_status"
  add_index "posts", ["topic"], :name => "index_posts_on_topic"

  create_table "species", :force => true do |t|
    t.string  "code",       :limit => 6
    t.string  "name_sci",                 :null => false
    t.string  "authority"
    t.string  "name_en",                  :null => false
    t.string  "name_ru"
    t.string  "name_uk"
    t.integer "index_num",                :null => false
    t.string  "order"
    t.string  "family",                   :null => false
    t.string  "avibase_id", :limit => 16
    t.string  "protonym"
  end

  add_index "species", ["code"], :name => "index_species_on_code"
  add_index "species", ["index_num"], :name => "index_species_on_index_num"
  add_index "species", ["name_sci"], :name => "index_species_on_name_sci"

end
