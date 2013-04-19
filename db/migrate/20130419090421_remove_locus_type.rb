class RemoveLocusType < ActiveRecord::Migration
  def up
    remove_column :loci, :loc_type
  end

  def down
  end
end
