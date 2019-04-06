class AddPatchFlagToLocus < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :patch, :boolean, default: 'f', null: false
  end
end
