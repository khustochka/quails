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

  def available_comments(post)
    post.comments
  end
end
