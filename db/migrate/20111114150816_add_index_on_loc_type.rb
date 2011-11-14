class AddIndexOnLocType < ActiveRecord::Migration
  def up
    change_column(:loci, :loc_type, :integer, :null => false)
    add_index "loci", [:loc_type]
  end

  def down
  end
end
