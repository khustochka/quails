module AdminController

  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :admin_layout?
  end

  def admin_layout?
    @admin_layout
  end
  private :admin_layout?

  module ClassMethods

    def administrative(options={})
      if Quails.env.ssl?
        before_action :force_ssl_for_admin, options
        # FIXME: seems not to work, but OK
        skip_before_action :force_http, options
      end
      requires_admin_authorized options
      before_action options do
        @admin_layout = true
      end
    end

  end
end
