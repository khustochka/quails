class MyStatsController < ApplicationController

  def index
    # Subquery is faster than join
    @total = MyObservation.distinct_species.count
    ukraine_subregions = Locus.find_by_slug('ukraine').subregion_ids
    @species_ukraine = MyObservation.distinct_species.filter(locus: ukraine_subregions).count

    @species_this_year = MyObservation.distinct_species.filter(year: 2013).count

    # Count over subquery is faster than Array#size
    rel = MyObservation.aggregate_by_species(:min).
        having("EXTRACT(year FROM MIN(observ_date)) = 2013")
    @new_this_year = Observation.from("(#{rel.to_sql}) AS obs").count

    # Year with max species
    @year_with_max_species = MyObservation.distinct_species.
        group("EXTRACT(YEAR from observ_date)").
        order("COUNT(DISTINCT species_id) DESC").
        limit(1).
        count("DISTINCT species_id").to_a.first

    # Month+year with max species
    @month_year_with_max_species = MyObservation.distinct_species.
        group("EXTRACT(YEAR from observ_date), EXTRACT(month from observ_date)").
        order("COUNT(DISTINCT species_id) DESC").
        limit(1).
        count("DISTINCT species_id")

    # Month with max species
    @month_with_max_species = MyObservation.distinct_species.
        group("EXTRACT(month from observ_date)").
        order("COUNT(DISTINCT species_id) DESC").
        limit(1).
        count("DISTINCT species_id").to_a.first
  end

end
