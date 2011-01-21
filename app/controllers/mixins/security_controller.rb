module SecurityController
  def self.included(klass)
    klass.extend ClassMethods
    klass.before_filter do
      @is_admin = instance_eval &CredentialsVerifier::CHECK_COOKIE_PROC
    end
  end

  module ClassMethods
    def require_http_auth(*args)
      options = args.extract_options!
      before_filter options do
        instance_eval &CredentialsVerifier::AUTH_PROC
        instance_eval &CredentialsVerifier::SET_COOKIE_PROC
      end
    end
  end
end