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

  def searchable_species
    obs = Observation.identified.select("species_id, COUNT(id) as weight").group(:species_id)
    Species.
        joins("LEFT OUTER JOIN (#{obs.to_sql}) obs on id = obs.species_id")
  end
end
