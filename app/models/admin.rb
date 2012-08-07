class Admin < User
  def admin?
    true
  end

  def available_posts
    Post.scoped
  end

  def available_loci
    Locus.scoped
  end
end
