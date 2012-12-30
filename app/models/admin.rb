class Admin < User
  def admin?
    true
  end

  def available_posts
    Post.all
  end

  def available_loci
    Locus.all
  end
end
