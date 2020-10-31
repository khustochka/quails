# frozen_string_literal: true

module App2::LinksHelper

  #FIXME: This method is not exactly compatible with link_to. No block argument!
  def external_link(name = nil, options = nil, html_options = nil)
    html_options2 = (html_options.dup || {}).stringify_keys!
    klass = html_options2["class"]
    case klass
    when String, Array
      html_options2["class"] << -" external"
    when NilClass
      html_options2["class"] = -"external"
    end

    nofollow = true
    if html_options2.has_key?(-"nofollow")
      nofollow = html_options2.delete(-"nofollow")
    end
    if nofollow
      html_options2[:rel] = -"nofollow"
    end
    link_to(name, options, html_options2)
  end

end
