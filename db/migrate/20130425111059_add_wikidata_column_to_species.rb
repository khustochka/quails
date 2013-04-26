class AddWikidataColumnToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :wikidata, :text
  end
end
