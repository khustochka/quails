module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :admin_session?
  end

  module ClassMethods
    def check_http_auth(*args)
      options = args.extract_options!
      before_filter options do
        if CredentialsVerifier.authenticate(self)
          CredentialsVerifier.set_cookie(self)
        else
          raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
        end
      end
    end
	
	
    def require_http_auth(*args)
      options = args.extract_options!
      before_filter options do
        CredentialsVerifier.require_auth(self) && CredentialsVerifier.set_cookie(self)
      end
    end
	
  end

  private
  def admin_session?
    return @is_admin unless @is_admin.nil? # true or false
    @is_admin = CredentialsVerifier.check_cookie(self)
  end
end