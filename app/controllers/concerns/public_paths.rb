# frozen_string_literal: true

module PublicPaths
  include PublicRoutesHelper

  def self.included(klass)
    klass.helper_method(
        :root_path, :root_url, :view_only_path
    ) if klass.respond_to? :helper_method
  end

  private

  def root_path(*args)
    blog_path(*args)
  end

  def root_url(*args)
    blog_url(*args)
  end

  def view_only_path
    true
  end

end
