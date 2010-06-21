module ApplicationHelper
  def default_window_caption
    Rails.env == 'development' ? '!!! - Set the window caption / quails3' : request.host
  end

  def include_stylesheets
      stylesheet_link_tag @stylesheets
  end

  def include_scripts
      javascript_include_tag @scripts
  end
end
