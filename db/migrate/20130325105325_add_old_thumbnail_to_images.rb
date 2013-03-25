class AddOldThumbnailToImages < ActiveRecord::Migration
  def change
    add_column :images, :has_old_thumbnail, :boolean, null: false, default: 'f'

    Image.update_all(has_old_thumbnail: true)
  end
end
