class RemoveParentIdFromLoci < ActiveRecord::Migration
  def change
    remove_index :loci, :parent_id
    remove_column :loci, :parent_id
  end
end
