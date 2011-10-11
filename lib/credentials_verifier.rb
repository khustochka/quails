module CredentialsVerifier

  def self.init(options)
    @options = Hashie::Mash.new(options)
    @free_access = Rails.env.development? && @options.free_access
  end

  def self.free_access
    @free_access
  end

  def self.check_credentials(username, password)
    (username == @options.username &&
        (Digest::SHA1.hexdigest(password) == @options.password || password == @options.password)) ||
        @free_access
  end
end