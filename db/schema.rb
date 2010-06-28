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

ActiveRecord::Schema.define(:version => 20100628161410) do

  create_table "locus", :force => true do |t|
    t.string  "code",      :null => false
    t.integer "parent_id"
    t.string  "loc_type",  :null => false
    t.string  "name_en"
    t.string  "name_ru"
    t.string  "name_uk"
    t.float   "lat"
    t.float   "lon"
  end

  add_index "locus", ["code"], :name => "index_locus_on_code"
  add_index "locus", ["loc_type"], :name => "index_locus_on_loc_type"
  add_index "locus", ["parent_id"], :name => "index_locus_on_parent_id"

  create_table "observations", :force => true do |t|
    t.integer "species_id"
    t.integer "locus_id"
    t.date    "observ_date",                   :null => false
    t.string  "quantity"
    t.string  "biotope"
    t.string  "place"
    t.string  "notes"
    t.boolean "mine",        :default => true
  end

  add_index "observations", ["locus_id"], :name => "index_observations_on_locus_id"
  add_index "observations", ["mine"], :name => "index_observations_on_mine"
  add_index "observations", ["observ_date"], :name => "index_observations_on_observ_date"
  add_index "observations", ["species_id"], :name => "index_observations_on_species_id"

  create_table "species", :force => true do |t|
    t.string  "code",       :limit => 6
    t.string  "name_sci",                :null => false
    t.string  "authority",               :null => false
    t.string  "name_en",                 :null => false
    t.string  "name_ru",                 :null => false
    t.string  "name_uk",                 :null => false
    t.integer "index_num",               :null => false
    t.string  "order",                   :null => false
    t.string  "family",                  :null => false
    t.string  "avibase_id",              :null => false
    t.string  "protonym"
  end

  add_index "species", ["code"], :name => "index_species_on_code"
  add_index "species", ["index_num"], :name => "index_species_on_index_num"
  add_index "species", ["name_sci"], :name => "index_species_on_name_sci"

end
