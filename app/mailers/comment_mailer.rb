class CommentMailer < ActionMailer::Base
  Configurator.configure(self)

  #default from: ENV['quails_comment_sender']
  #default to: ENV['quails_comment_reciever']

  def notify_admin(comment, host)
    if self.class.default_params[:to] && self.class.default_params[:from]
      @comment = comment
      @host = host
      mail subject: "Comment posted to \"#{@comment.post.formatted.title}\""
    end
  end

  def notify_parent_author(comment, host)
    to = comment.parent_comment.commenter.email
    if self.class.default_params[:from] && to.present?
      @comment = comment
      @host = host
      mail subject: "Ответ на ваш комментарий на birdwatch.org.ua (\"#{@comment.post.formatted.title}\")", to: to
    end
  end
end
