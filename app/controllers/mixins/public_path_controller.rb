module PublicPathController
  def self.included(klass)
    klass.helper_method :root_path, :root_url, :public_post_path, :public_image_path, :public_comment_path
  end

  private

  def public_post_path(post, options = {})
    show_post_path(post.to_url_params.merge(options))
  end

  def public_comment_path(comment, post = nil)
    post ||= comment.post
    public_post_path(post, :anchor => "comment#{comment.id}")
  end

  def public_image_path(img, options = {})
    show_image_path(img.to_url_params.merge(options))
  end

  def root_path
    blog_path
  end

  def root_url
    blog_url
  end

end
