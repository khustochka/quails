# frozen_string_literal: true

class CommentMailerPreview < ActionMailer::Preview
  def notify_parent_author
    comment = Comment.
        joins(parent_comment: :commenter).
        where.not(commenters: {email: ""}).
        where(parent_comments_comments: {send_email: true}).
        first
    CommentMailer.notify_parent_author(comment, "birdwatch.org.ua")
  end

  def notify_admin
    comment = Comment.
        joins(parent_comment: :commenter).
        where.not(commenters: {email: ""}).
        where(parent_comments_comments: {send_email: true}).
        first
    CommentMailer.notify_admin(comment, "birdwatch.org.ua")
  end
end
