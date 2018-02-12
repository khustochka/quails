class CommentMailerPreview < ActionMailer::Preview

  def notify_parent_author
    comment = Comment.where.not(parent_id: nil).joins(parent_comment: :commenter).where.not(commenters: {email: ""}).first
    CommentMailer.notify_parent_author(comment, "birdwatch.org.ua")
  end

end
