class AddParentIdToImage < ActiveRecord::Migration
  def change
    add_column :images, :parent_id, :integer
  end
end
