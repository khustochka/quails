# frozen_string_literal: true

module PublicPaths

  def self.included(klass)
    klass.helper_method(
        :root_path, :root_url
    ) if klass.respond_to? :helper_method
  end

  private

  def root_path(*args)
    blog_path(*args)
  end

  def root_url(*args)
    blog_url(*args)
  end

end
