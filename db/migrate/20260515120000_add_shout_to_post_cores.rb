# frozen_string_literal: true

class AddShoutToPostCores < ActiveRecord::Migration[8.1]
  def up
    add_column :post_cores, :shout, :boolean, default: false, null: false

    execute(<<~SQL)
      UPDATE post_cores
      SET shout = TRUE
      WHERE id IN (SELECT DISTINCT post_core_id FROM posts WHERE status = 'SHOT')
    SQL

    execute(<<~SQL)
      UPDATE posts SET status = 'OPEN' WHERE status = 'SHOT'
    SQL
  end

  def down
    execute(<<~SQL)
      UPDATE posts SET status = 'SHOT'
      WHERE post_core_id IN (SELECT id FROM post_cores WHERE shout = TRUE)
    SQL
    remove_column :post_cores, :shout
  end
end
