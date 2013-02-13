module PublicPathController
  def self.included(klass)
    klass.helper_method(
        :root_path, :root_url, :public_post_path, :public_comment_path
    ) if klass.respond_to? :helper_method
  end

  private

  include PublicRoutesHelper

  def root_path
    blog_path
  end

  def root_url
    blog_url
  end

end
