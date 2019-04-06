class AddAssetsCacheToImages < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :assets_cache, :text, null: false, default: ''
  end
end
