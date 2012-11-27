class RemoveLegacySlug < ActiveRecord::Migration
  def up
    remove_column :species, :legacy_slug
  end

  def down
  end
end
