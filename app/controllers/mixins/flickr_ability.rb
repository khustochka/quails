require 'flickr/client'

module FlickrAbility

  def self.included(klass)
    klass.helper_method :flickr
  end

  def flickr
    Flickr::Client.new
  end

end
