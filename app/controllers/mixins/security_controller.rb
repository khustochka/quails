module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :admin_session?
  end

  module ClassMethods
    def requires_admin_authorized(*args)
      options = args.extract_options!
      before_filter options do
        if authenticate_with_http_basic &CredentialsVerifier.method(:check_credentials)
          CredentialsVerifier.set_cookie(self)
        else
          raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
        end
      end
    end

    def ask_for_credentials(*args)
      options = args.extract_options!
      before_filter options do
        authenticate_or_request_with_http_basic &CredentialsVerifier.method(:check_credentials)
        CredentialsVerifier.set_cookie(self)
      end
    end
	
  end

  private
  def admin_session?
    return @is_admin unless @is_admin.nil? # true or false
    @is_admin = CredentialsVerifier.check_cookie(self)
  end
end