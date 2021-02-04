if ENV["SENDGRID_API_KEY"]
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :user_name => 'apikey',
    :password => ENV["SENDGRID_API_KEY"],
    :domain => 'birdwatch.org.ua',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
