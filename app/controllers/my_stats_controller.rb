class MyStatsController < ApplicationController

  def index
    # Subquery is faster than join
    @total = MyObservation.distinct_species.count
    ukraine_subregions = Locus.find_by_slug('ukraine').subregion_ids
    @species_ukraine = MyObservation.distinct_species.filter(locus: ukraine_subregions).count

    @species_this_year = MyObservation.distinct_species.filter(year: 2012).count

    # Count over subquery is faster than Array#size
    rel =MyObservation.aggregate_by_species(:min).
                    having("EXTRACT(year FROM MIN(observ_date)) = 2012")
    @new_this_year = Observation.from("(#{rel.to_sql}) AS obs").count
  end

end
