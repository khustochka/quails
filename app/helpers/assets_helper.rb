# frozen_string_literal: true

module AssetsHelper
  GMAP_API_VERSION = "3.62"
  GMAP_API_URL = -"https://maps.googleapis.com/maps/api/js?key=#{ENV["quails_google_maps_api_key"]}&v=#{GMAP_API_VERSION}"

  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets.concat args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts.concat args
  end
end
