module FlickrApp

  FLICKRAW_CACHE_KEY = :flickraw

  def self.configured?
    flickraw.api_key.present? && flickraw.shared_secret.present?
  end

  def self.expire!
    Rails.cache.delete(FLICKRAW_CACHE_KEY)
  end

  private

  def self.flickraw
    Rails.cache.fetch(FLICKRAW_CACHE_KEY) do
      FlickRaw.tap do |fr|
        fr.api_key = Settings.flickr_app.api_key
        fr.shared_secret = Settings.flickr_app.shared_secret
      end
    end
  end

  def self.client
    if FlickrApp.configured?
      flickraw::Flickr.new.tap do |fl|
        fl.access_token = Settings.flickr_admin.access_token
        fl.access_secret = Settings.flickr_admin.access_secret
      end
    end
  end

end
