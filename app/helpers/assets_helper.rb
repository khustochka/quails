module AssetsHelper
  def stylesheet(*args)
    @stylesheets ||= []
    @stylesheets += args
  end

  def javascript(*args)
    @scripts ||= []
    @scripts += args
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