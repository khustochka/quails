module CredentialsVerifier

  def self.init(options)
    @options = options
    @options.password ||= Digest::SHA1.hexdigest(options.password_plain)
  end

  def self.authenticate(controller)
    controller.authenticate_or_request_with_http_basic do |user_name, password|
      user_name == @options.username && Digest::SHA1.hexdigest(password) == @options.password
    end
  end

  def self.check_cookie(controller)
    controller.session[@options.admin_session_ask] == @options.admin_session_reply
  end

  def self.set_cookie(controller)
    controller.session[@options.admin_session_ask] = @options.admin_session_reply
  end
end