module FlickrApp
  def self.configured?
    if FlickRaw.api_key.present? && FlickRaw.shared_secret.present?
      true
    else
      FlickRaw.api_key = Settings.flickr_app.api_key
      FlickRaw.shared_secret = Settings.flickr_app.shared_secret
      FlickRaw.api_key.present? && FlickRaw.shared_secret.present?
    end
  end

  def flickr
    @flickr ||= FlickRaw::Flickr.new.tap do |fl|
      fl.access_token = Settings.flickr_admin.access_token
      fl.access_secret = Settings.flickr_admin.access_secret
    end

  end

end
