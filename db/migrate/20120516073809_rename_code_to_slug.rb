class RenameCodeToSlug < ActiveRecord::Migration[4.2]
  def up
    rename_column :posts, :code, :slug
    rename_column :images, :code, :slug
    rename_column :loci, :code, :slug

  end

  def down
    rename_column :posts, :slug, :code
    rename_column :images, :slug, :code
    rename_column :loci, :slug, :code
  end
end
