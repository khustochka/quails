# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  default from: ENV["quails_comment_sender"]
  default to: ENV["quails_comment_reader"]

  before_action :set_params

  def notify_admin
    mail subject: "Comment posted to \"#{sanitized_comment_title}\""
  end

  def notify_parent_author
    to = @comment.parent_comment.commenter.email
    if (Rails.env.production? && Quails.env.live?) ||
            (!Rails.env.production? && (!perform_deliveries || delivery_method.in?([:letter_opener, :test]))) && to.present?
      mail to: to, subject: "Ответ на ваш комментарий на сайте birdwatch.org.ua (\"#{sanitized_comment_title}\")"
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

  def sanitized_comment_title
    sanitize(@comment.post.decorated.title, tags: [])
  end
end
