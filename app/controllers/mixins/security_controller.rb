module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :admin_session?
  end

  module ClassMethods
    def require_http_auth(*args)
      options = args.extract_options!
      before_filter options do
        CredentialsVerifier.authenticate(self)
        CredentialsVerifier.set_cookie(self)
      end
    end
  end

  private
  def admin_session?
    return @is_admin unless @is_admin.nil?
    @is_admin = CredentialsVerifier.check_cookie(self)
  end
end