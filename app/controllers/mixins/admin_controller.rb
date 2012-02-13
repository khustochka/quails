module AdminController

  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods

    def administrative(options={})
      requires_admin_authorized options
      layout 'admin', options
      skip_before_filter :set_locale, options
      I18n.locale = :en
    end

  end
end