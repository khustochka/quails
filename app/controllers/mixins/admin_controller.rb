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
        force_ssl options
      end
      requires_admin_authorized options
      before_filter options do
        @admin_layout = true
      end
    end

  end
end
