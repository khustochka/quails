# frozen_string_literal: true

class ReportsController < ApplicationController
  administrative

  TWO_YEARS = 365 * 2 * 24 * 60 * 60

  def environ
    # @env = ENV
    @lc_ctype = ActiveRecord::Base.connection.select_rows("SHOW LC_CTYPE")[0][0]
    @pg_version = ActiveRecord::Base.connection.select_rows("SELECT version();")[0][0]
  end

  def insights
    @index_posts = Post.indexable.size
    @index_images = Image.indexable.size
    @index_species = Observation.identified.select(:species_id).distinct.size
    @comments = Comment.approved.size
    @user_comments = Comment.approved.
      left_outer_joins(:commenter).
      where("is_admin = 'f' OR commenters.id IS NULL").
      size
  end

  def index
  end

  def more_than_year
    @period = params[:days].to_i
    sort_val = params[:sort].try(:to_sym)
    if @period >= 30
      sort_col = sort_val || :date2
      query = MyObservation.joins(:card).select("species_id, observ_date").order("observ_date").to_sql
      @list = Observation.connection.select_rows(query).group_by(&:first).each_with_object([]) do |obsdata, collection|
        sp, obss = obsdata
        obs = obss.map { |_, d| Date.parse(d) }.each_cons(2).select do |ob1, ob2|
          (ob2 - ob1) >= @period
        end
        collection.concat(
          obs.map do |ob1, ob2|
            { sp_id: sp.to_i,
              date1: ob1,
              date2: ob2,
              days: (ob2 - ob1).to_i, }
          end
        )
      end.sort { |a, b| b[sort_col] <=> a[sort_col] }
      spcs = Species.where(id: @list.pluck(:sp_id)).index_by(&:id)
      @list.each do |item|
        item[:sp] = spcs[item[:sp_id]]
      end
    else
      redirect_to(days: 365, sort: sort_val)
    end
  end

  def topicture
    @species_with_media = Media.joins(:observations, :taxa).count("DISTINCT species_id")

    unpic_rel = MyObservation.select("species_id, COUNT(observations.id) AS cnt").where(
      "species_id NOT IN (%s)" %
        MyObservation.select("DISTINCT species_id").
          joins("INNER JOIN media_observations as im on (observations.id = im.observation_id)").to_sql
    ).group(:species_id)

    @no_photo = Species.select("*").
      joins("INNER JOIN (#{unpic_rel.to_sql}) AS obs ON species.id=obs.species_id").order("cnt DESC").
      where("cnt > 1")

    new_pic = MyObservation.joins(:images).select("species_id, MIN(media.created_at) as add_date").
      group(:species_id)
    @new_pics = Species.select("*").joins("INNER JOIN (#{new_pic.to_sql}) AS obs ON species.id=obs.species_id").
      limit(15).order("add_date DESC")

    long_rel = MyObservation.joins(:images, :card).select("species_id, MAX(observ_date) as lastphoto").
      group(:species_id).having("MAX(observ_date) < (now() - interval '3 years')")

    @long_time = Species.select("*").
      joins("INNER JOIN (#{long_rel.to_sql}) AS obs ON species.id=obs.species_id").order("lastphoto")

    sort_col = :date2

    @recent_2yrs =
      Image.joins(:observations).order(:created_at).preload(:species).merge(MyObservation.all).
        group_by { |i| i.species.first }.
        each_with_object([]) do |imgdata, collection|
          sp, imgs = imgdata

          img = imgs.each_cons(2).select do |im1, im2|
            im2.created_at > 1.year.ago.beginning_of_year && (im2.created_at - im1.created_at) >= TWO_YEARS
          end
          collection.concat(
            img.map do |im1, im2|
              { sp: sp,
                date1: im1.created_at.to_date,
                date2: im2.created_at.to_date, }
            end
          )
        end.sort { |a, b| b[sort_col] <=> a[sort_col] }
  end

  def this_day
    @month, @day = (params[:day].try(:split, "-") || [Time.current.month, Time.current.day]).map { |n| "%02d" % n.to_i }
    prev_day = Image.joins(:observations, :cards).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
      where("to_char(observ_date, 'MM-DD') < '#{@month}-#{@day}'").
      order(Arel.sql("to_char(observ_date, 'MM-DD') DESC")).first
    @prev_day = begin
      [prev_day[:imon], prev_day[:iday]].join("-")
    rescue
      nil
    end
    next_day = Image.joins(:observations, :cards).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
      where("to_char(observ_date, 'MM-DD') > '#{@month}-#{@day}'").
      order(Arel.sql("to_char(observ_date, 'MM-DD') ASC")).first
    @next_day = begin
      [next_day[:imon], next_day[:iday]].join("-")
    rescue
      nil
    end
    @images = Image.select("media.*, cards.observ_date").distinct.joins(:observations, :cards).
      where("EXTRACT(day from observ_date)::integer = ? AND EXTRACT(month from observ_date)::integer = ?", @day, @month).
      order("cards.observ_date ASC")
  end

  def uptoday
    @locations = Country.all

    observations_filtered = MyObservation.joins(:card)
    if params[:locus]
      loc_filter = Locus.find_by!(slug: params[:locus]).subregion_ids
      observations_filtered = observations_filtered.where("cards.locus_id" => loc_filter)
    end

    @today = Date.today
    @this_day = if params[:day]
      Date.parse("#{@today.year}-#{params[:day]}")
    else
      @today
    end
    @next_day = @this_day + 1
    @prev_day = @this_day - 1
    @uptoday = observations_filtered.
      where(
        'EXTRACT(month FROM observ_date)::integer < ? OR
        (EXTRACT(month FROM observ_date)::integer = ?
        AND EXTRACT(day FROM observ_date)::integer <= ?)',
        @this_day.month, @this_day.month, @this_day.day
      ).
      order(Arel.sql("EXTRACT(year FROM observ_date)::integer")).
      group("EXTRACT(year FROM observ_date)::integer").
      count("DISTINCT species_id")
    @max = @uptoday.map(&:second).max
  end

  def compare
    l1 = params[:loc1]
    l2 = params[:loc2]

    if l1 && l2
      @loc1 = Locus.find_by(slug: l1)
      @loc2 = Locus.find_by(slug: l2)

      observations_source = if @loc1.country == @loc2.country
        Card.where(locus_id: @loc1.country.subregion_ids)
      else
        Card.all
      end

      prespecies = Species.short.select('species."order", species.family').distinct.joins(:cards).merge(Taxon.listable)

      @species = prespecies.merge(observations_source).ordered_by_taxonomy.extend(SpeciesArray)

      @loc1_species = prespecies.merge(Card.where(locus_id: @loc1.subregion_ids)).to_a
      @loc2_species = prespecies.merge(Card.where(locus_id: @loc2.subregion_ids)).to_a
    else
      l1 ||= "kyiv"
      l2 ||= "brovary"
      redirect_to(loc1: l1, loc2: l2)
    end
  end

  def by_countries
    @countries = Country.all.to_a

    by_sps = {}

    @countries.each do |cnt|
      list = Species.
        joins(:cards).
        merge(Taxon.listable).
        where("cards.locus_id" => cnt.subregion_ids).
        distinct.
        ids
      list.each do |sp_id|
        by_sps[sp_id] ||= []
        by_sps[sp_id] << cnt
      end
    end
    @species = Species.where(id: by_sps.keys).index_by(&:id)

    @result = by_sps.group_by { |_, cnts| cnts.size }.to_a.sort { |a, b| b.first <=> a.first }
  end

  def stats
    @allowed_params = [:year, :locus]
    @years = [nil] + Observation.years
    @locations = Country.all

    observations_filtered = Observation.refine(year: params[:year]).joins(:card)
    if params[:locus]
      loc_filter = Locus.find_by!(slug: params[:locus]).subregion_ids
      observations_filtered = observations_filtered.where("cards.locus_id" => loc_filter)
    end
    identified_observations = observations_filtered.identified
    obs_with_taxon = observations_filtered.joins(:taxon)
    lifelist_filtered = LiferObservation.all
    lifelist_filtered = lifelist_filtered.where("EXTRACT(year from observ_date)::integer = ?", params[:year]) if params[:year]
    if params[:locus]
      loc_filter = Locus.find_by!(slug: params[:locus]).subregion_ids
      lifelist_filtered = lifelist_filtered.where(locus_id: loc_filter)
    end

    @year_data = obs_with_taxon.select('EXTRACT(year FROM observ_date)::integer as year,
                                      COUNT(observations.id) as count_obs,
                                      COUNT(DISTINCT observ_date) as count_days,
                                      COUNT(DISTINCT species_id) as count_species').
      group("EXTRACT(year FROM observ_date)").order("year")

    @first_sp_by_year =
      lifelist_filtered.group("EXTRACT(year FROM observ_date)::integer").count(:all)

    @month_data = obs_with_taxon.select('EXTRACT(month FROM observ_date)::integer as month,
                                      COUNT(observations.id) as count_obs,
                                      COUNT(DISTINCT species_id) as count_species').
      group("EXTRACT(month FROM observ_date)").order("month")
    @first_sp_by_month =
      lifelist_filtered.group("EXTRACT(month FROM observ_date)::integer").count(:all)

    @day_by_obs = observations_filtered.joins(:card).select("observ_date, COUNT(observations.id) as count_obs").
      group("observ_date").
      order(Arel.sql("COUNT(observations.id) DESC, observ_date ASC")).limit(10)

    dates = @day_by_obs.except(:select).select(:observ_date)
    @locs_for_day_by_obs =
      Card.select("DISTINCT locus_id, observ_date").where(observ_date: dates).preload(locus: :cached_parent).group_by(&:observ_date)

    @day_by_species = identified_observations.select("observ_date, COUNT(DISTINCT species_id) as count_species").
      group("observ_date").
      order(Arel.sql("COUNT(DISTINCT species_id) DESC, observ_date ASC")).limit(10)

    dates = @day_by_species.except(:select).select(:observ_date)
    @locs_for_day_by_species =
      Card.select("DISTINCT locus_id, observ_date").where(observ_date: dates).preload(locus: :cached_parent).group_by(&:observ_date)

    @day_and_loc_by_species = identified_observations.select("observ_date, locus_id, COUNT(DISTINCT species_id) as count_species").
      group("observ_date, locus_id").
      order(Arel.sql("COUNT(DISTINCT species_id) DESC, observ_date ASC")).
      limit(10)

    locs = @day_and_loc_by_species.except(:select).select(:locus_id)
    @preloaded_locs = Locus.where(id: locs).preload(:cached_parent).index_by(&:id)

    @day_by_new_species = lifelist_filtered.
      except(:select).select("observ_date, COUNT(species_id) as count_species").
      group("observ_date").except(:order).
      order(Arel.sql("COUNT(species_id) DESC, observ_date ASC")).limit(10)

    # FIXME: wrong locus may be shown if lifer is on several cards a day
    dates = @day_by_new_species.except(:select).select(:observ_date)
    @locs_for_day_by_new_species =
      lifelist_filtered.except(:select).
        select("DISTINCT locus_id, observ_date, card_id").
        where(subquery: { observ_date: dates }).
        preload(card: { locus: :cached_parent }).group_by(&:observ_date)

    @ebird_eligible_this_year = Card.ebird_eligible.in_year(params[:year] || Quails::CURRENT_YEAR).size
  end

  def voices
    @exclude_low_num = params[:exclude_low_num]
    base = Observation.joins(:taxon).where.not(taxa: { species_id: nil }).group("species_id")
    voiceful = base.select("taxa.species_id, COUNT(observations.id) as voicenum").where(voice: true)
    total = base.select("taxa.species_id, count(observations.id) as totalnum")
    @species = Species.find_by_sql("WITH voiceful AS (#{voiceful.to_sql}), total AS (#{total.to_sql})
                SELECT species.*, voicenum, totalnum, 100.00 * voicenum / totalnum as percentage
                FROM voiceful NATURAL JOIN total JOIN species on total.species_id = species.id
                WHERE voicenum <> 0 #{@exclude_low_num.presence && "AND totalnum > 10"}
                ORDER BY percentage DESC
                LIMIT 20")

    base = Observation.joins(:card).group("EXTRACT(month FROM observ_date)")
    voiceful = base.select("EXTRACT(month FROM observ_date) AS month, COUNT(observations.id) as voicenum").where(voice: true)
    total = base.select("EXTRACT(month FROM observ_date) AS month, count(observations.id) as totalnum")

    @month_data = Observation.find_by_sql("WITH voiceful AS (#{voiceful.to_sql}), total AS (#{total.to_sql})
                SELECT total.month, voicenum, totalnum, 100.00 * voicenum / totalnum as percentage
                FROM voiceful NATURAL JOIN total
                WHERE totalnum <> 0
                ORDER BY month ASC")
  end

  def charts
    @locations = Country.all

    observations_filtered = MyObservation.joins(:card)
    if params[:locus]
      loc_filter = Locus.find_by!(slug: params[:locus]).subregion_ids
      observations_filtered = observations_filtered.where("cards.locus_id" => loc_filter)
    end

    current = Quails::CURRENT_YEAR
    @data = {}
    @years =
      params[:years] ?
        Range.new(*params[:years].split("..").map(&:to_i)) :
        (current - 1)..current
    @years.each do |yr|
      list = observations_filtered.
        select("species_id, MIN(observ_date) as first_date").
        where("extract(year from observ_date) = ?", yr).
        group(:species_id)
      dates = Observation.from(list).order("first_date").
        group(:first_date).count(:species_id)
      @data[yr] = dates.inject([]) do |memo, (dt, cnt)|
        memo << [[dt.month, dt.day], (memo.last.try(&:last) || 0) + cnt]
      end
      last_day = Date.new(yr, 12, 31)
      if last_day > Date.today
        last_day = Date.today
      end
      last_day2 = [last_day.month, last_day.day]
      if @data[yr].any? && @data[yr].last.first != last_day2
        @data[yr] << [last_day2, @data[yr].last.second]
      end
    end
  end

  def month_targets
    @month = params[:month].to_i
    unless @month > 0 && @month < 13
      @month = Date.current.month
    end
    @locations = Locus.locs_for_lifelist
    @locus = Locus.find_by(slug: params[:locus])
    obs_base = Observation.all
    if @locus
      obs_base = obs_base.refine(locus: @locus.subregion_ids)
    end

    # Put prev & next months into [1..12] interval
    @prev_and_next = [@month - 1, @month + 1].map { |n| (n - 1) % 12 + 1 }
    species_of_this_month = obs_base.
      select("DISTINCT taxa.species_id").
      joins(:taxon, :card).
      where("EXTRACT(month from observ_date) = ?", @month).
      where.not(taxa: { species_id: nil })
    species_of_adjacent_months = obs_base.
      select("species_id").
      joins(:taxon, :card).
      where("EXTRACT(month from observ_date) IN (?)", @prev_and_next).
      where.not(taxa: { species_id: nil })
    @species = Species.
      where(id: species_of_adjacent_months).
      where.not(species: { id: species_of_this_month }).
      order("species.index_num").
      extending(SpeciesArray)
  end

  def clear_cache
    ClearCacheJob.perform_later
    redirect_to reports_path
  end

  def server_error
    raise "Intentionally produced Server Error"
  end
end
