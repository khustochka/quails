# frozen_string_literal: true

require "flickr/client"

module FlickrConcern
  def self.included(klass)
    klass.helper_method :_FlickrClient, :flickr_admin
  end

  private

  def _FlickrClient
    @flickr_client ||= ::Flickr::Client.new
  end

  def flickr_admin
    @flickr_admin ||= Settings.flickr_admin
  end
end
