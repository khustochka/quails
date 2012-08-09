module CredentialsCheck

  def self.extended(klass)
    Configurator.configure(klass)
  end

  def configure(options)
    @options = OpenStruct.new(options)
    @free_access = Rails.env.development? && @options.free_access
    raise ArgumentError, "You have to specify admin username and password" unless
        @free_access || (@options.username && @options.password)
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

  def check_credentials(username, password)
    (username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || password == @options.password)) ||
        @free_access
  end
end
