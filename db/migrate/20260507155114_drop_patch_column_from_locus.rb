class DropPatchColumnFromLocus < ActiveRecord::Migration[8.1]
  def change
    remove_column :loci, :patch, :boolean, default: false, null: false
  end
end
