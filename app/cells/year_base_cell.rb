# frozen_string_literal: true

module YearBaseCell
  def current
    all.first
  end

  def years
    if @back == "all"
      # In case there are no years in the DB default to this year and 2 previous
      min_year = observations.order(:observ_date).limit(1).pick(Arel.sql("EXTRACT(year from observ_date)::integer")) || year - 2
      (min_year..year).to_a.reverse.presence
    else
      ((year - @back)..year).to_a.reverse
    end
  end

  def lifers
    @lifers ||= LiferObservation.for_year(year).order(:observ_date).preload(taxon: :species)
  end

  private

  def observations
    MyObservation.joins(:card).refine(@observation_filter)
  end

  def list_query
    observations
      .where("EXTRACT(year FROM observ_date)::integer IN (?)", years)
      .order(Arel.sql("EXTRACT(year FROM observ_date)::integer"))
  end

  def year_lists
    return @year_lists if @year_lists.present?

    @year_lists = count_species(list_query)
  end

  def count_species(query)
    query
      .group("EXTRACT(year FROM observ_date)::integer")
      .count("DISTINCT species_id")
  end
end
