class AddPatchLocus < ActiveRecord::Migration[6.1]
  def change
    add_column :loci, :patch, :boolean, null: false, default: false
  end
end
