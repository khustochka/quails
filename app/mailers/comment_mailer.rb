# frozen_string_literal: true

class CommentMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  default from: ENV["COMMENT_EMAIL_SENDER"]
  default to: ENV["ADMIN_NOTIFICATIONS_EMAIL"]

  before_action :set_params

  def notify_admin
    mail subject: "Comment posted to \"#{sanitized_comment_title}\""
  end

  def notify_parent_author
    to = @comment.parent_comment.commenter.email
    if send_email_to_users? && to.present?
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

  def send_email_to_users?
    !perform_deliveries ||
      delivery_method.in?([:letter_opener, :test]) ||
      (Rails.env.production? && Quails.env.live?)
  end
end
