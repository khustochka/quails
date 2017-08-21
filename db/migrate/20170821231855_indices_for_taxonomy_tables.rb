class IndicesForTaxonomyTables < ActiveRecord::Migration[5.1]
  def change
    add_index :ebird_taxa, :ebird_code
    add_index :ebird_taxa, :parent_id
    add_index :ebird_taxa, :index_num

    add_index :taxa, :ebird_code
    add_index :taxa, :parent_id
    add_index :taxa, :index_num
    add_index :taxa, :species_id
    #add_index :taxa, :ebird_taxon_id

    add_index :species, :name_sci
    add_index :species, :index_num

    add_index :species_images, :image_id

    add_index :url_synonyms, :name_sci
  end
end
