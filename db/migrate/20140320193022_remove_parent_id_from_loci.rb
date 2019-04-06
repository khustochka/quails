class RemoveParentIdFromLoci < ActiveRecord::Migration[4.2]
  def change
    remove_index :loci, :parent_id
    remove_column :loci, :parent_id
  end
end
