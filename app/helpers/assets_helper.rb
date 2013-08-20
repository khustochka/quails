module AssetsHelper

  GMAP_API_URL = Rails.env.test? ?
      nil :
      'http://maps.googleapis.com/maps/api/js?v=3.13&sensor=false'

  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets.concat args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts.concat args
  end
end
