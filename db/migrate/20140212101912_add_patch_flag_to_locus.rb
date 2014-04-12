class AddPatchFlagToLocus < ActiveRecord::Migration
  def change
    add_column :loci, :patch, :boolean, default: 'f', null: false
  end
end
