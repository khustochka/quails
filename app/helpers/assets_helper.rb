module AssetsHelper
  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets.concat args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts.concat args
  end

  def use_gmap
    javascript(
        'http://maps.google.com/maps/api/js?sensor=false',
        'gmap3.min',
        'map.init'
    )
  end

  def use_jquery
    @jquery = true
  end
end
