class AddLegacySlugToPosts < ActiveRecord::Migration[8.1]
  def up
    add_column :posts, :legacy_slug, :string, limit: 64

    # Drop the single-column unique index first to allow slug deduplication across langs
    remove_index :posts, :slug

    # For English posts with -en suffix: save old slug as legacy, strip the suffix
    execute <<~SQL
      UPDATE posts
      SET legacy_slug = slug,
          slug = LEFT(slug, LENGTH(slug) - 3)
      WHERE lang = 'en' AND slug LIKE '%-en'
    SQL

    add_index :posts, [:slug, :lang], unique: true
    add_index :posts, :legacy_slug, unique: true, where: "legacy_slug IS NOT NULL"
  end

  def down
    # Restore -en suffix on English posts that have a legacy_slug
    execute <<~SQL
      UPDATE posts
      SET slug = legacy_slug
      WHERE lang = 'en' AND legacy_slug IS NOT NULL
    SQL

    remove_index :posts, [:slug, :lang]
    remove_index :posts, :legacy_slug
    add_index :posts, :slug, unique: true

    remove_column :posts, :legacy_slug
  end
end
