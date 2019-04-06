class AddSpeciesIdToLegacySpecies < ActiveRecord::Migration[4.2]
  def change
    add_column :legacy_species, :species_id, :integer
  end
end
