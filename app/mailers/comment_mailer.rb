class CommentMailer < ActionMailer::Base
  Configurator.configure(self)

  #default from: ENV['quails_comment_sender']
  #default to: ENV['quails_comment_reciever']

  def comment_posted(comment)
    if self.class.default_params[:to] && self.class.default_params[:from]
      @comment = comment
      mail subject: 'New comment posted'
    end
  end
end
