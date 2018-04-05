class DropParentIdFromMedia < ActiveRecord::Migration[5.1]
  def change
    remove_column :media, :parent_id
  end
end
