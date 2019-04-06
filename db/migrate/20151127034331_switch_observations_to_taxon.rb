class SwitchObservationsToTaxon < ActiveRecord::Migration[4.2]
  def change
    add_column :observations, :taxon_id, :integer, null: true
    rename_column :observations, :species_id, :legacy_species_id
    change_column :observations, :legacy_species_id, :integer, null: true
    add_index :observations, :taxon_id
  end
end
