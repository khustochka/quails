module Role
  module User

    def admin?
      false
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
      obs = Observation.identified.select("species_id, COUNT(observations.id) as weight").group(:species_id)
      Species.
          joins("INNER JOIN (#{obs.to_sql}) obs on id = obs.species_id")
    end

    def prepopulate_comment(comment)
      # No action
    end

  end
end
