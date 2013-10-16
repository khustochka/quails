module Flickr
  class Client

    class Chain
      def initialize(client)
        @current = client
        @errors = ActiveModel::Errors.new(self)
      end

      def method_missing(method, *args, &block)
        @current = @current.send(method, *args, &block)
      end
    end

    def initialize
      if configured?
        @client = FlickRaw::Flickr.new
        @client.access_token = Settings.flickr_admin.access_token
        @client.access_secret = Settings.flickr_admin.access_secret
      end
    end

    def configured?
      if @configured.nil?
        @configured = Flickr::Client.flickraw_configured?
      else
        @configured
      end
    end

    def self.reconfigure!
      FlickRaw.configure(Settings.flickr_app.api_key, Settings.flickr_app.shared_secret)
    end

    def method_missing(method, *args, &block)
      Chain.new(@client).send(method, *args, &block)
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
