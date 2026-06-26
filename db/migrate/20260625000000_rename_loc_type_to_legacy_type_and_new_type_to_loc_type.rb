class RenameLocTypeToLegacyTypeAndNewTypeToLocType < ActiveRecord::Migration[8.1]
  def change
    rename_column :loci, :loc_type, :legacy_type
    rename_column :loci, :new_type, :loc_type
  end
end
