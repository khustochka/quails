module AdminController
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def require_http_auth(*args)
      options = args.extract_options!
      before_filter :check_http_auth, options
    end
  end

  private
  def check_http_auth
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == 'user' && password == 'passwd'
    end
  end

end