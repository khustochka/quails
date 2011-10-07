module CredentialsVerifier

  def self.init(options)
    @options = options
  end

  def self.check_credentials(username, password)
    (username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || password == @options.password)) ||
        (Rails.env.development? && @options.free_access)
  end

  def self.check_cookie(controller)
    controller.session[@options.admin_session_ask] == @options.admin_session_reply
  end

  def self.set_cookie(controller)
    controller.session[@options.admin_session_ask] = @options.admin_session_reply
  end
end