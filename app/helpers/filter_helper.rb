require "wiki_filter"

module FilterHelper

  include WikiFilter

  def wiki_filter(post)
    auto_link(
        RedCloth.new(transform(post.text)).to_html
    ).html_safe
  end

end
