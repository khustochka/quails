module ApplicationHelper
  def default_page_title
    Rails.env.development? ? '!!! - Set the window caption / quails3' : request.host
  end

  def include_stylesheets
    stylesheet_link_tag @stylesheets.uniq
  end

  def include_scripts
    @scripts = ['jquery', 'rails'] + @scripts if @jquery
    javascript_include_tag @scripts.uniq
  end
end
