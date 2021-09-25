# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  default from: ENV["quails_comment_sender"]
  default to: ENV["quails_comment_reader"]

  before_action :set_params

  def notify_admin
    if self.class.default_params[:to] && self.class.default_params[:from]
      mail subject: "Comment posted to \"#{@comment.post.decorated.title}\""
    end
  end

  def notify_parent_author
    to = @comment.parent_comment.commenter.email
    if (Rails.env.production? && Quails.env.live?) ||
            (Rails.env.development? && (!perform_deliveries || delivery_method == :letter_opener)) &&
            self.class.default_params[:from] && to.present?
      mail subject: "Ответ на ваш комментарий на сайте birdwatch.org.ua (\"#{@comment.post.decorated.title}\")", to: to
    end
  end

  private

  def set_params
    @comment = params[:comment]
    @link_options = params[:link_options]
  end

  def default_url_options
    @link_options
  end
end
