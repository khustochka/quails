module CredentialsVerifier

  def self.init(options)
    const_set(:AUTH_PROC,
              lambda { authenticate_or_request_with_http_basic do |user_name, password|
                user_name == options.username && password == options.password
              end
              })
  end

end