class AddSpeciesIdToLegacySpecies < ActiveRecord::Migration
  def change
    add_column :legacy_species, :species_id, :integer
  end
end
