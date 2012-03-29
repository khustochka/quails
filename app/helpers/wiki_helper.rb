require "wiki_filter"

module WikiHelper

  include WikiFilter

  # TODO: redcloth over transfrom or vice versa? transform kills Textile's []; Textile kills my wiki "@" signs
  # for now, before release do transform first; i don't use textile markup on legacy site
  def wiki_filter(text)
    auto_link(
        RedCloth.new(transform(text), [:no_span_caps]).to_html
    ).html_safe
  end

  def comment_filter(text)
    # TODO: reduce the number of allowed tags ("a" is there now)
    # TODO: sanitize on save
    # TODO: do not sanitize comments left by admin
    RedCloth.new(transform(sanitize(text)), [:no_span_caps]).to_html.html_safe
  end

end
