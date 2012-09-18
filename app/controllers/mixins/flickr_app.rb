module FlickrApp
  def self.configured?
    @configured ||= reconfigure!
  end

  def self.reconfigure!
    FlickRaw.api_key = Settings.flickr_app.api_key
    FlickRaw.shared_secret = Settings.flickr_app.shared_secret
    @configured = flickraw_configured?
  end

  def flickr
    @flickr ||= (FlickRaw::Flickr.new.tap do |fl|
      fl.access_token = Settings.flickr_admin.access_token
      fl.access_secret = Settings.flickr_admin.access_secret
    end if FlickrApp.configured?)
  end

  private
  def self.flickraw_configured?
    FlickRaw.api_key.present? && FlickRaw.shared_secret.present?
  end

end
