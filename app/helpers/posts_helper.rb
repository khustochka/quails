module PostsHelper

  def post_link(text, blogpost, show_text_if_no_post = false)
    @only_path = true if @only_path.nil?
    if blogpost
      link_to(text, public_post_path(blogpost, only_path: @only_path), title: blogpost.formatted.title, class: ('grayout' unless blogpost.public?))
    else
      show_text_if_no_post ? text : nil
    end
  end

end
