# frozen_string_literal: true

class AddIndexCommentsParentId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :comments, :parent_id,
      name: :index_comments_on_parent_id,
      algorithm: :concurrently,
      if_not_exists: true
  end
end
