module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :current_user
  end

  module ClassMethods
    def requires_admin_authorized(*args)
      options = args.extract_options!
      before_filter options do
        unless current_user.admin?
          if current_user.has_admin_cookie?
            request_http_basic_authentication("Enter credentials")
          else
            raise ActionController::RoutingError, "Restricted path"
          end
        end
      end
    end

    def ask_for_credentials(*args)
      options = args.extract_options!
      before_filter options do
        unless current_user.admin?
          request_http_basic_authentication("Enter credentials")
        end
      end
    end

  end

  private
  def current_user
    @current_user ||=
        if (User.free_access || authenticate_with_http_basic(&User.method(:check_credentials))) && !params[:noadmin]
          Admin.new(cookies)
        else
          User.new(cookies)
        end
  end

end
