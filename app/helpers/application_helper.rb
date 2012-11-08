module ApplicationHelper

  def page_title
    strip_tags(@page_title) || default_page_title
  end

  def page_header
    @page_title
  end

  def default_page_title
    Rails.env.development? ? '!!! - Set the window caption / quails' : request.host
  end

  def link_to_or_span(name, options = {}, html_options = {})
    link_to_unless_current(name, options, html_options) do
      content_tag(:span, name, html_options)
    end
  end

end
