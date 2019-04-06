class AddPublicFlagToLocus < ActiveRecord::Migration[4.2]
  def change
    add_column :loci, :private_loc, :boolean, default: 'f', null: false
  end
end
