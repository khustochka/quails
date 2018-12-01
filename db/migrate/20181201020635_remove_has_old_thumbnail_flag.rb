class RemoveHasOldThumbnailFlag < ActiveRecord::Migration[5.2]
  def change
    remove_column :media, :has_old_thumbnail
  end
end
