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
          raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
        end
      end
    end

    def ask_for_credentials(*args)
      options = args.extract_options!
      before_filter options do
        unless CredentialsVerifier.free_access
          authenticate_or_request_with_http_basic &CredentialsVerifier.method(:check_credentials)
        end
      end
    end

  end

  private
  def current_user
    @current_user ||= User.new(authenticate_with_http_basic &CredentialsVerifier.method(:check_credentials))
  end

end