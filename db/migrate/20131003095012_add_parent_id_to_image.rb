class AddParentIdToImage < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :parent_id, :integer
  end
end
