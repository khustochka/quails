module PublicPathController
  def self.included(klass)
    klass.helper_method :public_post_path, :public_image_path
  end

  private

  def public_post_path(post, options = {})
    show_post_path(post.to_url_params.merge(options))
  end

  def public_image_path(img, options = {})
    show_image_path(img.to_url_params.merge(options))
  end

end
