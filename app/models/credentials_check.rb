module CredentialsCheck

  def self.extended(klass)
    Configurator.configure(klass)
  end

  def configure(options)
    @options = Hashie::Mash.new(options)
    @free_access = Rails.env.development? && @options.free_access
    unless @free_access || (@options.username && @options.password) || Quails.env.rake?
      raise ArgumentError, "You have to specify admin username and password"
    end
  end

  def free_access
    @free_access
  end

  def cookie_value
    @options.cookie_value
  end

  def cookie_name
    :quails_visitor
  end

  def has_admin_cookie?(cookies)
    User.cookie_value && cookies.signed[User.cookie_name] == User.cookie_value
  end

  def check_credentials(username, password)
    (username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || password == @options.password))
  end
end
