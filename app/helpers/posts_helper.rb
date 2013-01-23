module PostsHelper

  def post_link(text, blogpost, show_text_if_no_post = false)
    if blogpost
      link_to(text, public_post_path(blogpost), class: ('grayout' unless blogpost.public?))
    else
      show_text_if_no_post ? text : nil
    end
  end

  def post_title(post)
    wikify_one_line(post.title)
  end

end
