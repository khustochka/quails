class User
  def initialize(is_admin = false)
    @admin = is_admin
  end

  def available_posts
    @admin ? Post.scoped : Post.public
  end
end