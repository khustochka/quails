class RemoveOldFlickrDataColumn < ActiveRecord::Migration[4.2]
  def change
    remove_column :images, :flickr_data
    remove_column :images, :flickr_size
  end
end
