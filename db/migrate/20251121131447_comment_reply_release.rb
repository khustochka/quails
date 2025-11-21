class CommentReplyRelease < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :needs_reply_release, :boolean, default: false, null: false
    add_column :comments, :reply_released_at, :timestamp
  end
end
