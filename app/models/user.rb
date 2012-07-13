class User
  def initialize(is_admin = false)
    @is_admin = is_admin
  end

  def admin?
    @is_admin
  end

  def available_posts
    @is_admin ? Post.scoped : Post.public
  end

  def available_loci
    @is_admin ? Locus.scoped : Locus.public
  end
end
