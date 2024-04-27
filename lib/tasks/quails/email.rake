# frozen_string_literal: true

namespace :quails do
  namespace :email do
    desc "Preload eBird checklists"
    task test: :environment do
      ActionMailer::Base.mail(from: ENV["COMMENT_EMAIL_SENDER"], to: ENV["ADMIN_NOTIFICATIONS_EMAIL"], subject: "Comment mailer test", body: "This is a test of birdwatch.org.ua comment mailer.").deliver_now
    end
  end
end
