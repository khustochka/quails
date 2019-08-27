module UrlBuilder
  def self.included(klass)
    #klass.extend ClassMethods
    klass.helper_method :admin_pages_url_options
  end

  private

  # URL options for links to admin-only pages (that's why locale is forced to nil)
  def admin_pages_url_options
    @@admin_pages_url_options ||= {locale: nil}
  end

end

