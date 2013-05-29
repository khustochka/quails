class MyStatsController < ApplicationController

  def index
    # Subquery is faster than join
    @total = MyObservation.distinct_species.count
    ukraine_subregions = Locus.find_by_slug('ukraine').subregion_ids
    @species_ukraine = MyObservation.distinct_species.filter(locus: ukraine_subregions).count

    @species_this_year = MyObservation.distinct_species.filter(year: 2013).count

    # Count over subquery is faster than Array#size
    rel = MyObservation.joins(:card).aggregate_by_species(:min).
        having("EXTRACT(year FROM MIN(observ_date))::integer = 2013")
    @new_this_year = Observation.from("(#{rel.to_sql}) AS obs").count

    # Year with max species
    query = MyObservation.joins(:card).
        select("COUNT(DISTINCT species_id) as sp_count, EXTRACT(YEAR from observ_date)::integer as year").
        group("EXTRACT(YEAR from observ_date)::integer").
        order("sp_count DESC").
        limit(1)
    @year_with_max_species = Hashie::Mash.new(Observation.connection.select_one(query, "Year with max species"))

    # Month+year with max species
    query = MyObservation.joins(:card).
        select("COUNT(DISTINCT species_id) as sp_count, EXTRACT(YEAR from observ_date)::integer as year, EXTRACT(month from observ_date)::integer as month").
        group("EXTRACT(YEAR from observ_date)::integer, EXTRACT(month from observ_date)::integer").
        order("sp_count DESC").
        limit(1)
    @month_year_with_max_species = Hashie::Mash.new(Observation.connection.select_one(query, "Month, year with max species"))

    # Month with max species
    query = MyObservation.joins(:card).
        select("COUNT(DISTINCT species_id) as sp_count, EXTRACT(MONTH from observ_date)::integer as month").
        group("EXTRACT(month FROM observ_date)::integer").
        order("sp_count DESC").
        limit(1)
    @month_with_max_species = Hashie::Mash.new(Observation.connection.select_one(query, "Month with max species"))

    # Day with max species
    query = MyObservation.joins(:card).
        select("COUNT(DISTINCT species_id) as sp_count, observ_date").
        group("observ_date").
        order("sp_count DESC").
        limit(1)
    @day_with_max_species = Hashie::Mash.new(Observation.connection.select_one(query, "Day with max species"))

    # Day with max new species
    new_sp_query = MyObservation.joins(:card).select("species_id, MIN(observ_date) as observed_at").group(:species_id).to_sql
    query = Observation.
        select("COUNT(species_id) as sp_count, observed_at").
        from("(#{new_sp_query}) as new_sp_dates").
        group("observed_at").
        order("sp_count DESC").
        limit(1)
    @day_with_max_new_species = Hashie::Mash.new(Observation.connection.select_one(query, "Day with max new species"))

    # Newest species
    @newest_species = Lifelist.basic.relation.limit(1).first

    # Oldest species
    @oldest_species = Lifelist.advanced.sort('last').relation.reorder('last_seen ASC').limit(1).first

    # Most often seen species
    @most_often_species = Lifelist.advanced.sort('count').relation.limit(1).first

    # Species met only once # TODO: can be done via SQL
    @sp_met_once = MyObservation.group(:species_id).having('COUNT(id) = 1').count.size
  end

end
