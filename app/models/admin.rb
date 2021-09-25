# frozen_string_literal: true

class Admin
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
    obs = Observation.identified.select("species_id, COUNT(observations.id) as weight").group(:species_id)
    Species.
        joins("LEFT OUTER JOIN (#{obs.to_sql}) obs on species.id = obs.species_id")
  end

  def prepopulate_comment(comment)
    if commenter
      comment.commenter = commenter
      comment.name = commenter.name
      comment.send_email = true
    end
  end

  private
  def commenter
    @commenter ||= Commenter.where(is_admin: true).first
  end
end
