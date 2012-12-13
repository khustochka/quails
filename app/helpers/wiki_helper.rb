require "wiki_filter"

module WikiHelper

  include WikiFilter

  def wiki_filter(text)
    auto_link(
        RedCloth.new(transform(text), [:no_span_caps]).to_html,
        sanitize: false
    ).html_safe
  end

  def comment_filter(text)
    # TODO: reduce the number of allowed tags ("a" is there now)
    # TODO: sanitize on save
    # TODO: do not sanitize comments left by admin
    RedCloth.new(transform(sanitize(text)), [:no_span_caps]).to_html.html_safe
  end

  # For parsing titles and other one line strings
  def wikify_one_line(str)
    RedCloth.new(str, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

end
