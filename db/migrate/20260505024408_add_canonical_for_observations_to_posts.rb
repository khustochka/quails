# frozen_string_literal: true

class AddCanonicalForObservationsToPosts < ActiveRecord::Migration[8.1]
  class MigrationPost < ActiveRecord::Base
    self.table_name = "posts"
  end

  def up
    add_column :posts, :canonical_for_observations, :boolean, default: false, null: false

    backfill_from_attached_records
    backfill_orphan_slug_groups

    change_column_default :posts, :canonical_for_observations, from: false, to: nil
  end

  def down
    remove_column :posts, :canonical_for_observations
  end

  private

  # Any post that has cards or observations attached is canonical for its slug-group.
  def backfill_from_attached_records
    canonical_ids =
      MigrationPost.connection.select_values(<<~SQL).map(&:to_i).uniq
        SELECT post_id FROM cards WHERE post_id IS NOT NULL
        UNION
        SELECT post_id FROM observations WHERE post_id IS NOT NULL
      SQL

    return if canonical_ids.empty?

    MigrationPost.where(id: canonical_ids).update_all(canonical_for_observations: true)
  end

  # For any slug-group that ended up with no canonical post (no obs/cards attached
  # to any sibling), pick one by language priority: uk -> en -> ru -> anything else.
  def backfill_orphan_slug_groups
    lang_priority = Arel.sql(<<~SQL.squish)
      CASE lang
        WHEN 'uk' THEN 1
        WHEN 'en' THEN 2
        WHEN 'ru' THEN 3
        ELSE 4
      END
    SQL

    orphan_slugs =
      MigrationPost
        .group(:slug)
        .having("BOOL_OR(canonical_for_observations) = FALSE")
        .pluck(:slug)

    orphan_slugs.each do |slug|
      winner = MigrationPost
        .where(slug: slug)
        .order(lang_priority, :id)
        .first
      winner.update_columns(canonical_for_observations: true) if winner
    end
  end
end
