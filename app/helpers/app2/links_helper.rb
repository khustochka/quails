# frozen_string_literal: true

module App2
  module LinksHelper
    # FIXME: This method is not exactly compatible with link_to. No block argument!
    def external_link(name = nil, options = nil, html_options = nil)
      html_options2 = (html_options.dup || {}).stringify_keys!
      # dup is shallow, so build a new class value instead of appending to the caller's one.
      html_options2["class"] = (Array(html_options2["class"]) + ["external"]).join(" ")

      nofollow = true
      if html_options2.has_key?(-"nofollow")
        nofollow = html_options2.delete(-"nofollow")
      end
      if nofollow
        html_options2[:rel] = -"nofollow"
      end
      html_options2 = { target: :_blank }.merge(html_options2)
      link_to(name, options, html_options2)
    end
  end
end
