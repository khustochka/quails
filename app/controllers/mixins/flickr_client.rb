require 'flickr_app'

module FlickrClient

  def flickr
    FlickrApp.client
  end

end
