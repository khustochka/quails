# frozen_string_literal: true

class AddUniqueIndexCanonicalPostPerSlug < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :posts, :slug,
      name: :index_posts_on_canonical_slug,
      unique: true,
      algorithm: :concurrently,
      where: "canonical_for_observations",
      if_not_exists: true
  end
end
