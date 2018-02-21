module AssetsHelper

  # Stick to this API version. 3.32.2 has problems: not clickable labels on mobile and inconsistent zoom.
  GMAP_API_URL = -"//maps.googleapis.com/maps/api/js?key=#{ENV["quails_google_maps_api_key"]}&v=3.31.0"

  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets.concat args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts.concat args
  end
end
