class User
  extend CredentialsCheck

  def self.detect(session, cookies)
    if User.is_admin_session?(session)
      Admin.new(session, cookies)
    else
      User.new(session, cookies)
    end
  end

  def initialize(session, cookies)
    @session = session
    @cookies = cookies
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

  def drop_admin_session
    @session[User.cookie_name] = nil
  end

  def has_trust_cookie?
    User.has_trust_cookie?(@cookies)
  end

  def set_trust_cookie
    @cookies.signed[CredentialsCheck::TRUST_COOKIE_NAME] =
        {value: CredentialsCheck::TRUST_COOKIE_VALUE, expires: 1.month.from_now, httponly: true}
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
