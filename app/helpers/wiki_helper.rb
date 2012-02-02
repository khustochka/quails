require "wiki_filter"

module WikiHelper

  include WikiFilter

  def wiki_filter(text)
    auto_link(
        transform(RedCloth.new(text, [:no_span_caps]).to_html)
    ).html_safe
  end

  def comment_filter(text)
    #auto_link(
        simple_format(transform(text))
    #).html_safe
  end

end
