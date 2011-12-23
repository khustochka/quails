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
    use_jquery
    javascript(
        'http://maps.google.com/maps/api/js?sensor=false',
        'gmap3.min',
        'map'
    )
  end

  def use_jquery
    @jquery = true
  end

  def include_stylesheets
    stylesheet_link_tag @stylesheets.uniq if @stylesheets.present?
  end

  def include_scripts
    if @jquery
      @scripts ||= []
      @scripts = [JQUERY_URL, 'rails'] + @scripts
    end
    javascript_include_tag @scripts.uniq if @scripts.present?
  end
end
