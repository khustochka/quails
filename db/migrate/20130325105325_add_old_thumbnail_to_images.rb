class AddOldThumbnailToImages < ActiveRecord::Migration[4.2]

  class Image < ActiveRecord::Base

  end

  def change
    add_column :images, :has_old_thumbnail, :boolean, null: false, default: 'f'

    Image.update_all(has_old_thumbnail: true)
  end
end
