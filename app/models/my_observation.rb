class MyObservation < Observation

  # This class represents only observations that are mine and identified

  default_scope where(:mine => true).identified

  scope :distinct_species, select("DISTINCT species_id")

  def self.aggregate_by_species(*args)
    # for now argument should be :min, :max or :count
    select("species_id, #{args[0]}(observ_date)").group(:species_id)
  end

end
