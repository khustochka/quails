# frozen_string_literal: true

if ENV["MAILTRAP_API_TOKEN"]
  # require "json"
  # require "net/http"

  uri = URI.parse("https://mailtrap.io/api/v1/inboxes.json?api_token=#{ENV["MAILTRAP_API_TOKEN"]}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  first_inbox = JSON.parse(response.body)[0]

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name: first_inbox["username"],
    password: first_inbox["password"],
    address: first_inbox["domain"],
    domain: first_inbox["domain"],
    port: first_inbox["smtp_ports"][0],
    authentication: :plain,
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
