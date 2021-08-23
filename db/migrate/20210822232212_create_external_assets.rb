class CreateExternalAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :external_assets do |t|
      t.references :media, null: false
      t.string "service_name", null: false
      t.string "external_key", null: false
      t.text "metadata"

      t.timestamps
    end
    create_table :external_asset_variants do |t|
      t.references :external_asset, null: false
      # The key to find appropriate variant. For Flickr photos this would be just width.
      t.string "variation_key", null: false
      # Urls etc. It may make sense to extract url as a separate column later.
      t.text "metadata"

      t.timestamps
    end


  end
end
