class CreateBookSpecies < ActiveRecord::Migration[4.2]
  def change
    create_table "book_species" do |t|
      t.integer "authority_id",             :null => false
      t.integer "species_id"
      t.string  "name_sci",                 :null => false, limit: 255
      t.string  "authority",                :null => false, limit: 255
      t.string  "name_en",                  :null => false, limit: 255
      t.string  "name_ru",                  :null => false, limit: 255
      t.string  "name_uk",                  :null => false, limit: 255
      t.integer "index_num",                :null => false
      t.string  "order",                    :null => false, limit: 255
      t.string  "family",                   :null => false, limit: 255
      t.string  "avibase_id", :limit => 16
    end
    add_index "book_species", ["authority_id"], :name => "index_book_species_on_authority_id"
    add_index "book_species", ["index_num"], :name => "index_book_species_on_index_num"
    add_index "book_species", ["name_sci"], :name => "index_book_species_on_name_sci", :unique => true
  end
end
