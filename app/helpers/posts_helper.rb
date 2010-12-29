module PostsHelper

  # TODO: implement correct body parsing and transform
  def post_body(post)
    content_tag(:p, post.text.gsub(/(\r?\n){2}/,"\n</p>\n<p>\n").html_safe)
  end

end
