class AddWikidataColumnToSpecies < ActiveRecord::Migration[4.2]
  def change
    add_column :species, :wikidata, :text
  end
end
