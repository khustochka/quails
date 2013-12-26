class MyStatsController < ApplicationController

  def index
    observations_filtered = Observation.joins(:card)
    identified_observations = observations_filtered.identified
    lifelist_filtered = Lifelist.basic.relation

    @year_data = identified_observations.group('EXTRACT(year FROM observ_date)::integer').
        order('EXTRACT(year FROM observ_date)::integer')

    @first_sp_by_year = lifelist_filtered.group('EXTRACT(year FROM first_seen)::integer').
        except(:order)

    @countries = Country.all

    country_mapper = @countries.map do |c|
      " WHEN locus_id IN (#{c.subregion_ids.join(', ')}) THEN #{c.id} "
    end.join
    country_sql = "(CASE #{country_mapper} END)"

    @grouped_by_country = identified_observations.group(country_sql)

    @grouped_by_year_and_country = identified_observations.
        group('EXTRACT(year FROM observ_date)::integer', country_sql)


  end

end
