# frozen_string_literal: true

class LifelistController < ApplicationController
  layout "application2", only: [:index]

  administrative only: [:chart]

  localized

  def index
    @list_life = Lifelist::FirstSeen.full
    @list_current_year = Lifelist::FirstSeen.over(year: Quails::CURRENT_YEAR)

    @list_prev_year = Lifelist::FirstSeen.over(year: Quails::CURRENT_YEAR - 1)

    @list_canada = Lifelist::FirstSeen.over(locus: "canada")
    @list_ukraine = Lifelist::FirstSeen.over(locus: "ukraine")
    @list_usa = Lifelist::FirstSeen.over(locus: "usa")
    @list_uk = Lifelist::FirstSeen.over(locus: "united_kingdom")
    @list_pl = Lifelist::FirstSeen.over(locus: "poland")
  end

  def basic
    allow_params(:year, :locus, :sort)

    sort_override =
      case params[:sort]
      when nil
        nil
      when "by_taxonomy"
        "class"
      else
        raise ActionController::RoutingError, "Illegal argument sort=#{params[:sort]}"
      end

    locus = params[:locus]
    @locations = Country.all

    raise ActiveRecord::RecordNotFound if locus && !locus.in?(@locations.map(&:slug))

    @lifelist = Lifelist::FirstSeen
      .over(params.permit(:year, :locus))
      .sort(sort_override)

    unless helpers.blogless_locale?
      @lifelist.posts_scope = current_user.available_posts
    end
  end

  def advanced
    allow_params(:year, :locus, :sort, :month, :day, :motorless, :exclude_heard_only)

    @locations = Locus.locs_for_lifelist

    locus = params[:locus]

    raise ActiveRecord::RecordNotFound if locus && !locus.in?(current_user.available_loci.map(&:slug))

    @lifelist = Lifelist::Advanced
      .over(params.permit(:year, :month, :day, :locus, :motorless, :exclude_heard_only))
      .sort(params[:sort])

    unless helpers.blogless_locale?
      @lifelist.posts_scope = current_user.available_posts
    end
  end

  def winter
    allow_params(:year, :locus, :sort, :motorless, :exclude_heard_only)

    @locations = Locus.locs_for_lifelist

    locus = params[:locus]

    raise ActiveRecord::RecordNotFound if locus && !locus.in?(current_user.available_loci.map(&:slug))

    @lifelist = Lifelist::Advanced
      .over(params.permit(:year, :locus, :motorless, :exclude_heard_only).merge({ winter: true }))
      .sort(params[:sort])

    unless helpers.blogless_locale?
      @lifelist.posts_scope = current_user.available_posts
    end

    render "advanced"
  end

  def ebird
    allow_params(:year, :locus, :sort)
    @lifelist = Lifelist::EBird.new(sort: params[:sort])
  end

  def stats
    observations_filtered = Observation.joins(:card)
    identified_observations = observations_filtered.identified
    lifelist_filtered = LiferObservation.all

    @year_data = identified_observations.group("EXTRACT(year FROM observ_date)::integer")
      .order(Arel.sql("EXTRACT(year FROM observ_date)::integer"))

    @first_sp_by_year = lifelist_filtered.group("EXTRACT(year FROM observ_date)::integer")
      .except(:order)

    @countries = Country.all

    country_mapper = @countries.map do |c|
      " WHEN locus_id IN (#{c.subregion_ids.join(", ")}) THEN #{c.id} "
    end.join
    country_sql = "(CASE #{country_mapper} END)"

    @grouped_by_country = identified_observations.group(country_sql)

    @grouped_by_year_and_country = identified_observations
      .group("EXTRACT(year FROM observ_date)::integer", country_sql)
  end

  def chart
    @page_title = "Test the summary / progress charts"
    year = params[:year]&.slice(/\d{4}/)&.to_i || Quails::CURRENT_YEAR
    @cell0 = YearSummaryCell.new(year: year - 1)
    @cell = YearProgressCell.new(year: year, offset: 8.hours)
  end
end
