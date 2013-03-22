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

  def available_comments(post)
    post.comments
  end
end
