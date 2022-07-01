# frozen_string_literal: true

module PostsHelper
  def post_link(text, blogpost, show_text_if_no_post = false, options = {})
    force_text = show_text_if_no_post.dup
    opts = options.dup
    # In case options are the 3rd parameter
    if show_text_if_no_post.is_a?(Hash)
      force_text = false
      opts = show_text_if_no_post
    end
    if blogpost
      link_to(text, public_post_url(blogpost, opts), title: blogpost.decorated.title, class: ("grayout" unless blogpost.public?))
    else
      force_text ? text : nil
    end
  end

  def post_cover_image_url(post)
    if post.cover_image_slug.present?
      if /\Ahttps?:\/\//.match?(post.cover_image_slug)
        post.cover_image_slug
      elsif img = Image.find_by_slug(post.cover_image_slug)
        static_jpg_url(img, { only_path: false })
      end
    end
  end
end
