require "config_reader"

options = ConfigReader.config_data

secret = options.secret_token
if secret.blank? || secret.length < 30
  raise ArgumentError, "A secret is required to generate an " +
      "integrity hash for cookie session data. Use " +
      "SecureRandom.hex(30) to generate a secret " +
      "of at least 30 characters and store it " +
      "in config/security.yml"
end
Quails3::Application.config.secret_token = secret

IMAGES_HOST = options.images_host

if flickr_data = options.flickr
  FlickRaw.api_key = flickr_data['api_key']
  FlickRaw.shared_secret = flickr_data['shared_secret']

  flickr.access_token = flickr_data['access_token']
  flickr.access_secret = flickr_data['access_key']
end
