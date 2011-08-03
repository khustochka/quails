require "wiki_filter"

module FilterHelper

  include WikiFilter

  def wiki_filter(post)
    simple_format(auto_link(
                      transform(post.text)
                  )).html_safe
  end

end
