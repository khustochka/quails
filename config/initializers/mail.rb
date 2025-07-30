# frozen_string_literal: true

if ENV["MAILTRAP_API_TOKEN"]
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name: "smtp@mailtrap.io",
    password: ENV["MAILTRAP_API_TOKEN"],
    domain: "birdwatch.org.ua",
    address: "live.smtp.mailtrap.io",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
elsif ENV["SENDGRID_API_KEY"]
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name: "apikey",
    password: ENV["SENDGRID_API_KEY"],
    domain: "birdwatch.org.ua",
    address: "smtp.sendgrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
elsif ENV["USE_SES"]
  # Enable `aws-sdk-rails` gem if you need to use this.
  ActionMailer::Base.delivery_method = :ses
end
