module CredentialsCheck

  TRUST_COOKIE_NAME = 'quails_visit'
  TRUST_COOKIE_VALUE = 'I believe you'

  def self.extended(klass)
    Configurator.configure(klass)
  end

  def configure(options)
    @options = Hashie::Mash.new(options)
    unless (@options.username && @options.password) || Quails.env.rake?
      raise ArgumentError, "You have to specify admin username and password"
    end
  end

  def cookie_value
    @options.cookie_value
  end

  def cookie_name
    :is_admin
  end

  def is_admin_session?(session)
    User.cookie_value && session[User.cookie_name] == User.cookie_value
  end

  def fully_authorised_admin_session?(request)
    ssl_gate(request) && is_admin_session?(request.session)
  end

  def has_trust_cookie?(cookies)
    cookies.signed[TRUST_COOKIE_NAME] == TRUST_COOKIE_VALUE
  end

  def check_credentials(username, password)
    username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || (!Rails.env.production? && password == @options.password))
  end

  private
  def ssl_gate(request)
    !Quails.env.ssl? || request.ssl?
  end
end
