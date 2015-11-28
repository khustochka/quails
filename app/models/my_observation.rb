class MyObservation < Observation

  # FIXME: no need in separate class, or rename
  # This class represents only observations that are dentified

  default_scope { identified }

  scope :distinct_species, lambda { joins(:taxon).select("DISTINCT species_id") }

  def self.aggregate_by_species(*args)
    # for now argument should be :min, :max or :count
    select("species_id, #{args[0]}(observ_date)").group(:species_id)
  end

end
