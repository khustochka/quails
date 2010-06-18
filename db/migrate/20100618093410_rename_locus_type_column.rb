class RenameLocusTypeColumn < ActiveRecord::Migration
  def self.up
    rename_column :loci, :type, :loc_type
  end

  def self.down
    rename_column :loci, :loc_type, :type
  end
end
