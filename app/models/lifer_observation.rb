class LiferObservation < Observation

  default_scope do
    identified.
        select("species_id, MIN(observ_date) AS first_met").
        joins(:card).
        group(:species_id).
        order("MIN(observ_date) DESC").
        preload(:species)
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
