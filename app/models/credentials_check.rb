module CredentialsCheck

  TRUST_COOKIE_NAME = 'quails_visit'
  TRUST_COOKIE_VALUE = 'I believe you'

  CredentialsOptions = Struct.new(:username, :password, :cookie_value)

  def self.extended(klass)
    klass.configure
  end

  def configure
    @options = CredentialsOptions.new(
        ENV['admin_username'],
        ENV['admin_password'],
        ENV['admin_cookie_value']
    )
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

  def check_credentials(username, password)
    username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || (!Rails.env.production? && password == @options.password))
  end

  private
  def ssl_gate(request)
    !Quails.env.ssl? || request.ssl?
  end
end
