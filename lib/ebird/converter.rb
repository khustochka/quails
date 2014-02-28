class EbirdConverter

  def initialize

  end

  def to_a(obs)
    [obs.card.observ_date, obs.species.name_sci, obs.card.locus.name_en]
  end

end
