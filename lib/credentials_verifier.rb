module CredentialsVerifier

  def self.init(options)
    options.password ||= Digest::SHA1.hexdigest(options.password_plain)

    const_set(:AUTH_PROC,
              lambda { authenticate_or_request_with_http_basic do |user_name, password|
                user_name == options.username && Digest::SHA1.hexdigest(password) == options.password
              end
              })

    const_set(:CHECK_COOKIE_PROC,
              lambda {
                session[:donttell] == 'dontask'
              })

    const_set(:SET_COOKIE_PROC,
              lambda {
                session[:donttell] = 'dontask'
              })

  end
end