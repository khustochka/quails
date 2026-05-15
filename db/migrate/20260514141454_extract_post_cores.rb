# frozen_string_literal: true

class ExtractPostCores < ActiveRecord::Migration[8.1]
  def up
    # 1. Create post_cores table.
    create_table :post_cores do |t|
      t.string :slug, limit: 64, null: false
      t.string :legacy_slug, limit: 64
      t.string :topic, limit: 4, null: false
      t.string :cover_image_slug
      t.text :lj_data
      t.boolean :publish_to_facebook, default: false, null: false
      t.timestamps null: false
    end

    add_index :post_cores, :slug, unique: true
    add_index :post_cores, :legacy_slug, unique: true, where: "legacy_slug IS NOT NULL"

    # 2. Backfill post_cores from posts: one row per slug, taking attributes
    #    from the canonical post. legacy_slug coalesced from whichever
    #    sibling has it set (only one ever does).
    execute <<~SQL
      INSERT INTO post_cores (slug, legacy_slug, topic, cover_image_slug, lj_data, publish_to_facebook, created_at, updated_at)
      SELECT
        canonical.slug,
        legacy.legacy_slug,
        canonical.topic,
        canonical.cover_image_slug,
        canonical.lj_data,
        canonical.publish_to_facebook,
        canonical.updated_at,
        canonical.updated_at
      FROM posts canonical
      LEFT JOIN LATERAL (
        SELECT legacy_slug FROM posts s
        WHERE s.slug = canonical.slug AND s.legacy_slug IS NOT NULL
        LIMIT 1
      ) legacy ON TRUE
      WHERE canonical.canonical_for_observations = TRUE
    SQL

    # 3. Add post_core_id to posts, backfill, then NOT NULL.
    add_reference :posts, :post_core, foreign_key: true, index: true
    execute <<~SQL
      UPDATE posts
      SET post_core_id = post_cores.id
      FROM post_cores
      WHERE post_cores.slug = posts.slug
    SQL
    change_column_null :posts, :post_core_id, false

    # 4. Add post_core_id to cards/observations, backfill via posts.post_id → posts.post_core_id.
    add_reference :cards, :post_core, foreign_key: { on_delete: :nullify }, index: true
    add_reference :observations, :post_core, foreign_key: { on_delete: :nullify }, index: true

    execute <<~SQL
      UPDATE cards
      SET post_core_id = posts.post_core_id
      FROM posts
      WHERE posts.id = cards.post_id
    SQL

    execute <<~SQL
      UPDATE observations
      SET post_core_id = posts.post_core_id
      FROM posts
      WHERE posts.id = observations.post_id
    SQL

    # 5. Drop the now-redundant columns and their indexes/FKs.
    remove_foreign_key :cards, :posts
    remove_foreign_key :observations, :posts
    remove_index :cards, :post_id
    remove_index :observations, :post_id
    remove_column :cards, :post_id
    remove_column :observations, :post_id

    # Drop posts indexes that reference the columns we are about to drop.
    remove_index :posts, name: "index_posts_on_legacy_slug"
    remove_index :posts, name: "index_posts_on_slug_and_lang"
    remove_index :posts, name: "index_posts_on_canonical_slug"

    remove_column :posts, :slug
    remove_column :posts, :legacy_slug
    remove_column :posts, :topic
    remove_column :posts, :cover_image_slug
    remove_column :posts, :lj_data
    remove_column :posts, :publish_to_facebook
    remove_column :posts, :canonical_for_observations

    # 6. Replacement uniqueness: one post per (post_core_id, lang).
    add_index :posts, [:post_core_id, :lang], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
