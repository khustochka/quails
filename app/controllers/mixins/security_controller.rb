module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :current_user
  end

  module ClassMethods
    def requires_admin_authorized(*args)
      options = args.extract_options!
      before_filter options do
        if current_user.admin?
          #PASS
        elsif current_user.potential_admin?
          authenticate_or_request_with_http_basic &CredentialsVerifier.method(:check_credentials)
        else
          raise ActionController::RoutingError, "Restricted path"
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
    @current_user ||=
        if CredentialsVerifier.free_access || authenticate_with_http_basic(&CredentialsVerifier.method(:check_credentials))
          User.new(admin: true)
        elsif cookies.signed[CredentialsVerifier.cookie_name] == CredentialsVerifier.cookie_value
          User.new(potential_admin: true)
        else
          User.new
        end
  end

end
