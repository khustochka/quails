module CredentialsVerifier

  def self.init(options)
    const_set(:AUTH_PROC,
              lambda { authenticate_or_request_with_http_basic do |user_name, password|
                expected_passwd = Rails.env.test? ? password : Digest::SHA1.hexdigest(password)
                user_name == options.username && expected_passwd == options.password
              end
              })
  end

end