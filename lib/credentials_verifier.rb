module CredentialsVerifier

  def self.init(options)
    @options = options
  end

  def self.check_credentials(username, password)
    (username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || password == @options.password)) ||
        (Rails.env.development? && @options.free_access)
  end
end