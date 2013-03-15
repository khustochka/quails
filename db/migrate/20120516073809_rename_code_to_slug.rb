class RenameCodeToSlug < ActiveRecord::Migration
  def up
    rename_column :posts, :code, :slug
    rename_column :images, :code, :slug
    rename_column :loci, :code, :slug

    rename_index :posts, :index_posts_on_code, :index_posts_on_slug
    rename_index :images, :index_images_on_code, :index_images_on_slug
    rename_index :loci, :index_locus_on_code, :index_loci_on_slug

    rename_index :loci, :index_locus_on_parent_id, :index_loci_on_parent_id
    rename_index :posts, :index_posts_on_created_at, :index_posts_on_face_date
  end

  def down
    rename_column :posts, :slug, :code
    rename_column :images, :slug, :code
    rename_column :loci, :slug, :code

    rename_index :posts, :index_posts_on_slug, :index_posts_on_code
    rename_index :images, :index_images_on_slug, :index_images_on_code
    rename_index :loci, :index_loci_on_slug, :index_locus_on_code

    rename_index :loci, :index_loci_on_parent_id, :index_locus_on_parent_id
    rename_index :posts, :index_posts_on_face_date, :index_posts_on_created_at
  end
end
