module ApplicationHelper

  def page_title
    strip_tags(@page_title).try(:html_safe) || default_page_title
  end

  def page_header
    @page_header || @page_title
  end

  def default_page_title
    Rails.env.development? ? '!!! - Set the window caption / quails' : request.host
  end

  def link_to_or_span(name, options = {}, html_options = {})
    link_to_unless_current(name, options, html_options) do
      content_tag(:span, name, html_options)
    end
  end

  def filtering_link_to_all(parameter)
    if params[parameter].nil?
      content_tag(:span, t('misc.all'))
    else
      link_to(t('misc.all'), significant_params.merge(parameter => nil))
    end
  end

  def sorting_link_to(text)
    params[:sort].nil? ? text : link_to(text, params.merge(:sort => nil))
  end

  def feed_icon
    link_to(
        image_tag('/img/rss_32x32.png', alt: t('misc.feed'), title: t('misc.feed')),
        {:controller => :feeds, :action => @feed, :format => :xml},
        class: 'img feed'
    )
  end

end
