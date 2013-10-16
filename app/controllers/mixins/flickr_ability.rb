require 'flickr_app'

module FlickrAbility

  def flickr
    FlickrApp.client
  end

end
