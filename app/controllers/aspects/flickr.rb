require 'flickr/client'

module Aspects
  module Flickr

    def self.included(klass)
      klass.helper_method :flickr_client, :flickr_admin
    end

    def flickr_client
      @flickr_client ||= ::Flickr::Client.new
    end

    def flickr_admin
      @flickr_admin ||= Settings.flickr_admin
    end

  end
end
