module PublicPathController
  def self.included(klass)
    klass.helper_method :public_post_path, :public_image_path
  end

  private

  def public_post_path(post)
    show_post_path(post.to_url_params)
  end

  def public_image_path(img)
    show_image_path(img.to_url_params)
  end

end
