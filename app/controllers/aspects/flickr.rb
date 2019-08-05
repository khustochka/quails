require 'flickr/client'

module Aspects
  module Flickr

    def self.included(klass)
      klass.helper_method :_FlickrClient, :flickr_admin
    end

    def _FlickrClient
      @flickr_client ||= ::Flickr::Client.new
    end

    def flickr_admin
      @flickr_admin ||= Settings.flickr_admin
    end

  end
end
