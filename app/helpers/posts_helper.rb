module PostsHelper

  class PseudoPost < Hashie::Mash

    def to_url_params
      {:id => code, :year => year, :month => month}
    end

    def year
      face_date.year.to_s
    end

    def month
      '%02d' % face_date.month
    end
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
