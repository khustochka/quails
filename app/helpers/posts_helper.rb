module PostsHelper

  # TODO: implement correct body parsing and transform
  def post_body(post)
    content_tag(:p, post.text.gsub(/(\r?\n){2}/,"\n</p>\n<p>\n").html_safe)
  end

  def post_link(text, blogpost, show_text_if_no_post = false)
    blogpost.nil? ? 
        (show_text_if_no_post ? text : nil) :
        link_to(text, public_post_path(blogpost), :class => blogpost.status != 'OPEN' ? 'grayout' : nil)
  end

  def lj_post_url
    "http://stonechat.livejournal.com/#{@post.lj_url_id}.html"
  end

end
