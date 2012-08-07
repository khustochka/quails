class User
  extend CredentialsCheck

  def initialize(options = {})
    @options = options
  end

  def admin?
    @is_admin ||= @options[:admin]
  end

  def potential_admin?
    @options[:potential_admin]
  end

  def available_posts
    admin? ? Post.scoped : Post.public
  end

  def available_loci
    admin? ? Locus.scoped : Locus.public
  end
end
