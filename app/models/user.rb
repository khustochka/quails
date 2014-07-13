class User
  extend CredentialsCheck

  def self.detect(request)
    if User.fully_authorised_admin_session?(request)
      Admin.new(request)
    else
      User.new(request)
    end
  end

  def initialize(request)
    @session = request.session
    @cookies = request.cookie_jar
  end

  def admin?
    false
  end

  def is_admin_session?
    User.is_admin_session?(@session)
  end

  def set_admin_session
    if User.cookie_value
      @session[User.cookie_name] = User.cookie_value
    end
  end

  def has_trust_cookie?
    User.has_trust_cookie?(@cookies)
  end

  def set_trust_cookie
    @cookies.signed[CredentialsCheck::TRUST_COOKIE_NAME] =
        {value: CredentialsCheck::TRUST_COOKIE_VALUE, expires: 1.month.from_now, httponly: true}
  end

  def available_posts
    Post.public_posts
  end

  def available_loci
    Locus.locs_for_lifelist
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
