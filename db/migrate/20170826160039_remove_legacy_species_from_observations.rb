class RemoveLegacySpeciesFromObservations < ActiveRecord::Migration[5.1]
  def change
    remove_column :observations, :legacy_species_id
  end
end
