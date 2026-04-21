# frozen_string_literal: true

class AddIndexCommentsCommenterId < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :comments, :commenter_id,
      name: :index_comments_on_commenter_id,
      algorithm: :concurrently,
      where: "commenter_id IS NOT NULL",
      if_not_exists: true
  end
end
