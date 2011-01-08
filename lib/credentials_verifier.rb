module CredentialsVerifier
  AUTH_PROC =
      lambda { authenticate_or_request_with_http_basic do |user_name, password|
        user_name == 'user' && password == 'passwd'
      end
      }
end