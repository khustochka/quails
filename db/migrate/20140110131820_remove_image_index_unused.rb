class RemoveImageIndexUnused < ActiveRecord::Migration[4.2]
  def change
    remove_index :images, name: "index_images_on_index_num"
  end
end
