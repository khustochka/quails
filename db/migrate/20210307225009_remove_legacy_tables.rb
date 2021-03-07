class RemoveLegacyTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :legacy_taxa
    drop_table :legacy_species
    drop_table :books
  end
end
