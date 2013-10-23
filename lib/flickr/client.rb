require 'monads/either'

module Flickr
  class Client

    def self.new
      if flickraw_configured?
        client = FlickRaw::Flickr.new
        admin = Settings.flickr_admin
        client.access_token = admin.access_token
        client.access_secret = admin.access_secret
        Either.value(client)
      else
        Either.error("No Flickr API key or secret defined!")
      end
    end

    def self.reconfigure!
      FlickRaw.configure(Settings.flickr_app.api_key, Settings.flickr_app.shared_secret)
    end

    private

    def self.flickraw_configured?
      if FlickRaw.configured?
        return true
      else
        reconfigure!
        FlickRaw.configured?
      end
    end

  end

end
