class User
  extend CredentialsCheck

  def initialize(cookies)
    @cookies = cookies
  end

  def admin?
    false
  end

  def has_admin_cookie?
    @cookies.signed[User.cookie_name] == User.cookie_value
  end

  def set_admin_cookie
    @cookies.signed[User.cookie_name] = {value: User.cookie_value, expires: 1.month.from_now}
  end

  def available_posts
    Post.public
  end

  def available_loci
    Locus.public
  end
end
