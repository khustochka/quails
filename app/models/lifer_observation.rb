class LiferObservation < Observation

  default_scope do
    identified.
        select("species_id, MIN(observ_date) AS first_met").
        joins(:card).
        group(:species_id).
        order("MIN(observ_date) DESC").
        preload(:species)
  end

  class ActiveRecord_Relation
    def generate
      Species.
          select("species.*, first_met").
          joins("INNER JOIN (#{self.to_sql}) AS lifeobs ON species.id=lifeobs.species_id").
          order('first_met')
    end
  end

  def self.total_count
    except(:group).except(:order).count("DISTINCT species_id")
  end

  def self.filter_locus(locus)
    lc = Locus.find_by!(slug: locus)
    super(lc.subregion_ids)
  end

  def post
    nil
  end

end
