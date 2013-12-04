class User
  extend CredentialsCheck

  def initialize(cookies)
    @cookies = cookies
  end

  def admin?
    false
  end

  def has_admin_cookie?
    User.has_admin_cookie?(@cookies)
  end

  def set_admin_cookie
    if User.cookie_value
      @cookies.signed[User.cookie_name] = {value: User.cookie_value, expires: 1.month.from_now}
    end
  end

  def remove_admin_cookie
    if User.cookie_value
      @cookies.delete(User.cookie_name)
    end
  end

  def available_posts
    Post.public
  end

  def available_loci
    Locus.public
  end

  def available_comments(post)
    post.comments.approved
  end

  def searchable_species
    obs = Observation.identified.select("species_id, COUNT(id) as weight").group(:species_id)
    Species.
        joins("INNER JOIN (#{obs.to_sql}) obs on id = obs.species_id")
  end

  def prepopulate_comment(comment)
    # No action
  end

end
