require 'flickr/client'

module FlickrAbility

  def self.included(klass)
    klass.helper_method :flickr, :flickr_admin
  end

  def flickr
    @flickr ||= Flickr::Client.new
  end

  def flickr_admin
    @flickr_admin ||= Settings.flickr_admin
  end

end
