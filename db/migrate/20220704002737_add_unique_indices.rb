class AddUniqueIndices < ActiveRecord::Migration[7.0]
  def change
    add_index :cards, :ebird_id, unique: true, where: "ebird_id IS NOT NULL"
    add_index :settings, :key, unique: true
    remove_index :species, :name_sci
    add_index :species, :name_sci, unique: true
    add_index :species, :code, unique: true
    add_index :species, :legacy_code, unique: true
    remove_index :url_synonyms, :name_sci
    add_index :url_synonyms, :name_sci, unique: true
  end
end
