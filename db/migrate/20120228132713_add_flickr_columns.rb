class AddFlickrColumns < ActiveRecord::Migration
  def up
    add_column :images, :flickr_id, :string, limit: 64
    add_column :images, :flickr_data, :text
    add_column :images, :flickr_size, :string, limit: 1
  end

  def down
    remove_column :images, :flickr_id
    remove_column :images, :flickr_data
    remove_column :images, :flickr_size
  end
end
