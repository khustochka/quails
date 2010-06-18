# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100618093410) do

  create_table "loci", :force => true do |t|
    t.string  "code",      :null => false
    t.integer "parent_id"
    t.string  "loc_type",  :null => false
    t.string  "name_en"
    t.string  "name_ru"
    t.string  "name_uk"
    t.float   "lat"
    t.float   "lon"
  end

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
  end

end
