# frozen_string_literal: true

class EmailTestJob < ApplicationJob
  queue_as :low

  def perform
    ActionMailer::Base
      .mail(
        from: ENV["COMMENT_EMAIL_SENDER"],
        to: ENV["ADMIN_NOTIFICATIONS_EMAIL"],
        subject: "Comment mailer test",
        body: "This is a test of birdwatch.org.ua comment mailer."
      )
      .deliver_now
  end
end
