require 'monads/either'
require 'flickraw-cached'

module Flickr

  include Either

  class Client

    def self.new
      if flickraw_configured?
        client = FlickRaw::Flickr.new
        admin = Settings.flickr_admin
        client.access_token = admin.access_token
        client.access_secret = admin.access_secret
        Value.new(client)
      else
        Error.new("No Flickr API key or secret defined!")
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

  class Value
    include Either::Value

    def method_missing(method, *args, &block)
      begin
        Value.new(@value.send(method, *args, &block))
      rescue FlickRaw::Error => e
        Error.new(e.message)
      end
    end

  end

  class Error
    include Either::Error
  end

  VALUE_CLASS = Value
  ERROR_CLASS = Error

end
