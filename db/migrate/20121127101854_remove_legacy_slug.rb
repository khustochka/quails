class RemoveLegacySlug < ActiveRecord::Migration[4.2]
  def up
    remove_column :species, :legacy_slug
  end

  def down
  end
end
