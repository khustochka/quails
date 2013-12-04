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
end
