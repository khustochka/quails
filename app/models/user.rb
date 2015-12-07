class User

  extend CredentialsCheck

  def self.from_session(request)
    user = new(request)
    if ssl_gate(request) && user.is_admin_session?
      user.extend(Role::Admin)
    else
      user.extend(Role::User)
    end
    user
  end

  def initialize(request)
    @session = request.session
    @cookies = request.cookie_jar
  end

  def is_admin_session?
    User.cookie_value && @session[User.cookie_name] == User.cookie_value
  end

  def set_admin_session
    if User.cookie_value
      @session[User.cookie_name] = User.cookie_value
    end
  end

  def has_trust_cookie?
    @cookies.signed[CredentialsCheck::TRUST_COOKIE_NAME] == CredentialsCheck::TRUST_COOKIE_VALUE
  end

  def set_trust_cookie
    @cookies.signed[CredentialsCheck::TRUST_COOKIE_NAME] =
        {value: CredentialsCheck::TRUST_COOKIE_VALUE, expires: 1.month.from_now, httponly: true}
  end

end
