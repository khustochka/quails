class RemoveLocusType < ActiveRecord::Migration[4.2]
  def up
    remove_column :loci, :loc_type
  end

  def down
  end
end
