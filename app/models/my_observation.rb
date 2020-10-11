# frozen_string_literal: true

class MyObservation < Observation

  # FIXME: no need in separate class, or rename
  # This class represents only observations that are identified

  default_scope { identified }

  scope :distinct_species, lambda { joins(:taxon).select("DISTINCT species_id") }

  # FIXME: this is bad and cause N+1 queries when preload(:taxon => :species) is used! Have to find workarounds.
  # belongs_to :species

  def self.aggregate_by_species(*args)
    # for now argument should be :min, :max or :count
    select("species_id, #{args[0]}(observ_date)").group(:species_id)
  end

end
