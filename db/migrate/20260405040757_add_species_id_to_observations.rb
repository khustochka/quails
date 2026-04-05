# frozen_string_literal: true

class AddSpeciesIdToObservations < ActiveRecord::Migration[8.1]
  def up
    add_column :observations, :species_id, :integer

    execute <<~SQL
      UPDATE observations
      SET species_id = taxa.species_id
      FROM taxa
      WHERE taxa.id = observations.taxon_id
    SQL

    # species_id can be null for unidentified taxa (no species record)
    add_index :observations, [:species_id, :card_id], where: "species_id IS NOT NULL"
    add_foreign_key :observations, :species, column: :species_id
  end

  def down
    remove_foreign_key :observations, column: :species_id
    remove_index :observations, [:species_id, :card_id]
    remove_column :observations, :species_id
  end
end
