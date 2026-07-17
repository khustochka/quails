# frozen_string_literal: true

require "test_helper"

class EmailTestJobTest < ActiveJob::TestCase
  test "delivers a test message to the admin" do
    ENV["COMMENT_EMAIL_SENDER"] = "sender@example.com"
    ENV["ADMIN_NOTIFICATIONS_EMAIL"] = "admin@example.com"

    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      EmailTestJob.perform_now
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["sender@example.com"], mail.from
    assert_equal ["admin@example.com"], mail.to
    assert_equal "Comment mailer test", mail.subject
  ensure
    ENV.delete("COMMENT_EMAIL_SENDER")
    ENV.delete("ADMIN_NOTIFICATIONS_EMAIL")
  end

  test "runs on the low priority queue" do
    assert_equal "low", EmailTestJob.new.queue_name
  end
end
