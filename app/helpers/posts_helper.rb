module PostsHelper

  def post_link(text, blogpost, show_text_if_no_post = false)
    if blogpost.nil?
      show_text_if_no_post ? text : nil
    else
      link_to(text, public_post_path(blogpost), :class => ('grayout' if blogpost.status != 'OPEN'))
    end
  end

  def post_title(post)
    RedCloth.new(post.title, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

  def lj_post_url
    "http://stonechat.livejournal.com/#{@post.lj_url_id}.html"
  end

end
