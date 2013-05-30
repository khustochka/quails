class AddAssetsCacheToImages < ActiveRecord::Migration
  def change
    add_column :images, :assets_cache, :text, null: false, default: ''
  end
end
