require "configurator"

options = Configurator.config_data

Configurator.configure_secret_token

if (flickr_data = options.flickr) && flickr_data['api_key']
  FlickRaw.api_key = flickr_data['api_key']
  FlickRaw.shared_secret = flickr_data['shared_secret']

  flickr.access_token = flickr_data['access_token']
  flickr.access_secret = flickr_data['access_key']
end
