class AddPublicFlagToLocus < ActiveRecord::Migration
  def change
    add_column :loci, :private_loc, :boolean, default: 'f', null: false
  end
end
