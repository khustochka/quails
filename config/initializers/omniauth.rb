if ENV["quails_facebook_app_secret"].present?
  OmniAuth.config.logger = Rails.logger

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, ENV["quails_facebook_app_id"], ENV["quails_facebook_app_secret"],
             info_fields: "name,email,link"
    provider :flickr, ENV["quails_flickr_app_key"], ENV["quails_flickr_app_secret"], scope: "write"
  end
end
