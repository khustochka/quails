class CommentMailer < ActionMailer::Base

  default from: ENV['quails_comment_sender']
  default to: ENV['quails_comment_reader']

  def notify_admin(comment, host)
    if self.class.default_params[:to] && self.class.default_params[:from]
      @comment = comment
      @host = host
      mail subject: "Comment posted to \"#{@comment.post.decorated.title}\""
    end
  end

  def notify_parent_author(comment, host)
    to = comment.parent_comment.commenter.email
    if Rails.env.production? && Quails.env.real_prod? && self.class.default_params[:from] && to.present?
      @comment = comment
      @host = host
      mail subject: "Ответ на ваш комментарий на birdwatch.org.ua (\"#{@comment.post.decorated.title}\")", to: to
    end
  end
end
