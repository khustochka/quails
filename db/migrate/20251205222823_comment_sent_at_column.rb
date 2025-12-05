class CommentSentAtColumn < ActiveRecord::Migration[8.1]
  def change
    rename_column :comments, :needs_reply_release, :needs_email_release
    rename_column :comments, :reply_released_at, :email_sent_at
  end
end
