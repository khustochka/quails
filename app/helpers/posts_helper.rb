module PostsHelper

  def post_link(text, blogpost, show_text_if_no_post = false)
    @only_path = true if @only_path.nil?
    if blogpost
      link_to(text, public_post_url(blogpost, only_path: @only_path), title: blogpost.decorated.title, class: ('grayout' unless blogpost.public?))
    else
      show_text_if_no_post ? text : nil
    end
  end

  def post_cover_image_url(post)
    if post.cover_image_slug.present?
      if post.cover_image_slug =~ /\Ahttps?:\/\//
        post.cover_image_slug
      elsif img = Image.find_by_slug(post.cover_image_slug)
        static_jpg_url(img, {only_path: false})
      end
    end

  end

end
