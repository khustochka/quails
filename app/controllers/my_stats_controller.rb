class MyStatsController < ApplicationController

  def index
    # Subquery is faster than join
    @total = MyObservation.distinct_species.count
    observations_filtered = Observation.joins(:card)
    identified_observations = observations_filtered.identified
    lifelist_filtered = Lifelist.basic.relation

    @year_data = identified_observations.select('EXTRACT(year FROM observ_date)::integer as year,
                                      COUNT(observations.id) as count_obs,
                                      COUNT(DISTINCT observ_date) as count_days,
                                      COUNT(DISTINCT species_id) as count_species').
        group('EXTRACT(year FROM observ_date)').order('year')

    @first_sp_by_year = lifelist_filtered.group('EXTRACT(year FROM first_seen)::integer').except(:order).count(:all)

  end

end
