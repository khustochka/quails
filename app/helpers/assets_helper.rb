module AssetsHelper

  GMAP_API_URL = 'http://maps.googleapis.com/maps/api/js?sensor=false'

  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets.concat args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts.concat args
  end
end
