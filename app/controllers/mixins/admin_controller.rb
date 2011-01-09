module AdminController
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def require_http_auth(*args)
      options = args.extract_options!
      before_filter options do
        instance_eval &CredentialsVerifier::AUTH_PROC
      end
    end
  end
end