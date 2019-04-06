class AddIndexOnLocType < ActiveRecord::Migration[4.2]
  def up
    change_column(:loci, :loc_type, :integer, :null => false)
    add_index "loci", [:loc_type]
  end

  def down
  end
end
