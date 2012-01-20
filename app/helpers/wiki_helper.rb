require "wiki_filter"

module WikiHelper

  include WikiFilter

  def wiki_filter(post)
    auto_link(
        transform(RedCloth.new(post.text, [:no_span_caps]).to_html)
    ).html_safe
  end

end
