require 'monads/either'
require 'flickraw-cached'

module Flickr

  include Either

  class Result
    include Either::Value

    def method_missing(method, *args, &block)
      begin
        Result.new(@value.send(method, *args, &block))
      rescue FlickRaw::Error => e
        Error.new(e.message)
      end
    end

  end

  class Error
    include Either::Error
  end

  Flickr::VALUE_CLASS = Result
  Flickr::ERROR_CLASS = Error

  class << Flickr
    self.send(:alias_method, :result, :value)
  end

  class Client

    def self.new
      if flickraw_configured?
        client = FlickRaw::Flickr.new
        admin = Settings.flickr_admin
        client.access_token = admin.access_token
        client.access_secret = admin.access_secret
        Flickr.result(client)
      else
        Flickr.error("No Flickr API key or secret defined!")
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
