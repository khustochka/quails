class MyStatsController < ApplicationController

  def index
    # Subquery is faster than join
    @total = MyObservation.distinct_species.count
    ukraine_subregions = Locus.find_by_slug('ukraine').subregion_ids
    @species_ukraine = MyObservation.distinct_species.filter(locus: ukraine_subregions).count

    @species_this_year = MyObservation.distinct_species.filter(year: 2012).count
    @new_this_year = Lifelist.basic.relation.where("EXTRACT(YEAR FROM first_seen) = 2012").count
  end

end
