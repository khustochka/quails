class ResearchController < ApplicationController

  administrative

  def environ
    #@env = ENV
  end

  def insights
  end

  def index
  end

  def more_than_year
    if params[:days]
      sort_col = params[:sort].try(:to_sym) || :date2
      @period = params[:days].to_i
      query = MyObservation.joins(:card).select("species_id, observ_date").order('observ_date').to_sql
      @list = Observation.connection.select_rows(query).group_by(&:first).each_with_object([]) do |obsdata, collection|
        sp, obss = obsdata
        obs = obss.map { |_, d| Date.parse(d) }.each_cons(2).select do |ob1, ob2|
          (ob2 - ob1) >= @period
        end
        collection.concat(
            obs.map do |ob1, ob2|
              {:sp_id => sp.to_i,
               :date1 => ob1,
               :date2 => ob2,
               :days => (ob2 - ob1).to_i}
            end
        )
      end.sort { |a, b| b[sort_col] <=> a[sort_col] }
      spcs = Species.where(id: @list.map { |i| i[:sp_id] }).index_by(&:id)
      @list.each do |item|
        item[:sp] = spcs[item[:sp_id]]
      end
    else
      redirect_to(days: 365)
    end
  end

  def topicture
    unpic_rel = MyObservation.select('species_id, COUNT(observations.id) AS cnt').where(
        "species_id NOT IN (%s)" %
            MyObservation.select('DISTINCT species_id').
                joins('INNER JOIN images_observations as im on (observations.id = im.observation_id)').to_sql
    ).group(:species_id)

    @no_photo = Species.select('*').
        joins("INNER JOIN (#{unpic_rel.to_sql}) AS obs ON species.id=obs.species_id").order('cnt DESC')

    new_pic = MyObservation.joins(:images).select("species_id, MIN(created_at) as add_date").
        group(:species_id)
    @new_pics = Species.select('*').joins("INNER JOIN (#{new_pic.to_sql}) AS obs ON species.id=obs.species_id").
        limit(15).order('add_date DESC')

    long_rel = MyObservation.joins(:images, :card).select("species_id, MAX(observ_date) as lastphoto").
        group(:species_id).having("MAX(observ_date) < (now() - interval '2 years')")

    @long_time = Species.select('*').
        joins("INNER JOIN (#{long_rel.to_sql}) AS obs ON species.id=obs.species_id").order('lastphoto')


    sort_col = :date2
    period = 365 * 2 * 24 * 60 * 60
    @recent_2yrs = Image.joins(:observations).order(:created_at).preload(:species).merge(MyObservation.all).
        group_by { |i| i.species.first }.each_with_object([]) do |imgdata, collection|

      sp, imgs = imgdata

      img = imgs.each_cons(2).select do |im1, im2|
        im2.created_at > Date.new(2012).beginning_of_year && (im2.created_at - im1.created_at) >= period
      end
      collection.concat(
          img.map do |im1, im2|
            {:sp => sp,
             :date1 => im1.created_at.to_date,
             :date2 => im2.created_at.to_date}
          end
      )
    end.sort { |a, b| b[sort_col] <=> a[sort_col] }

  end

  def day
    @month, @day = (params[:day].try(:split, '-') || [Time.current.month, Time.current.day]).map { |n| "%02d" % n.to_i }
    prev_day = Image.joins(:observations, :cards).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
        where("to_char(observ_date, 'MM-DD') < '#@month-#@day'").
        order("to_char(observ_date, 'MM-DD') DESC").first
    @prev_day = [prev_day[:imon], prev_day[:iday]].join('-') rescue nil
    next_day = Image.joins(:observations, :cards).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
        where("to_char(observ_date, 'MM-DD') > '#@month-#@day'").
        order("to_char(observ_date, 'MM-DD') ASC").first
    @next_day = [next_day[:imon], next_day[:iday]].join('-') rescue nil
    @images = Image.joins(:observations, :cards).
        where('EXTRACT(day from observ_date)::integer = ? AND EXTRACT(month from observ_date)::integer = ?', @day, @month)
  end

  def uptoday
    @today = Date.today
    @this_day = if params[:day]
                 Date.parse("#{@today.year}-#{params[:day]}")
               else
                 @today
               end
    @next_day = @this_day + 1
    @prev_day = @this_day - 1
    @uptoday = MyObservation.
        joins(:card).
        where(
        'EXTRACT(month FROM observ_date)::integer < ? OR
        (EXTRACT(month FROM observ_date)::integer = ?
        AND EXTRACT(day FROM observ_date)::integer <= ?)',
        @this_day.month, @this_day.month, @this_day.day
    ).
        order('EXTRACT(year FROM observ_date)::integer').
        group('EXTRACT(year FROM observ_date)::integer').
        count('DISTINCT species_id')
    @max = @uptoday.map(&:second).max
  end

  def compare
    l1 = params[:loc1]
    l2 = params[:loc2]

    if l1 && l2
      @loc1 = Locus.find_by_slug(l1)
      @loc2 = Locus.find_by_slug(l2)

      observations_source = if @loc1.country == @loc2.country
                              Card.where(locus_id: @loc1.country.subregion_ids)
                            else
                              Card.all
                            end

      prespecies = Species.uniq.joins(:cards).merge(MyObservation.all)

      @species = prespecies.merge(observations_source).ordered_by_taxonomy.extend(SpeciesArray)

      @loc1_species = prespecies.merge(Card.where(locus_id: @loc1.subregion_ids)).to_a
      @loc2_species = prespecies.merge(Card.where(locus_id: @loc2.subregion_ids)).to_a
    else
      l1 ||= 'kiev'
      l2 ||= 'brovary'
      redirect_to(loc1: l1, loc2: l2)
    end
  end

  def stats
    @years = [nil] + MyObservation.years

    #FIXME: not counting unidentified species for now, and seem we cannot do it easily without splitting queries
    observations_filtered = Observation.filter(year: params[:year]).joins(:card)
    identified_observations = observations_filtered.identified
    lifelist_filtered = Lifelist.basic.relation
    lifelist_filtered = lifelist_filtered.where('EXTRACT(year from first_seen)::integer = ?', params[:year]) if params[:year]

    @year_data = identified_observations.select('EXTRACT(year FROM observ_date)::integer as year,
                                      COUNT(observations.id) as count_obs,
                                      COUNT(DISTINCT observ_date) as count_days,
                                      COUNT(DISTINCT species_id) as count_species').
                group('EXTRACT(year FROM observ_date)').order('year')

    @first_sp_by_year = lifelist_filtered.group('EXTRACT(year FROM first_seen)::integer').except(:order).count(:all)

    @month_data = identified_observations.select('EXTRACT(month FROM observ_date)::integer as month,
                                      COUNT(observations.id) as count_obs,
                                      COUNT(DISTINCT species_id) as count_species').
        group('EXTRACT(month FROM observ_date)').order('month')
    @first_sp_by_month = lifelist_filtered.group('EXTRACT(month FROM first_seen)::integer').except(:order).count(:all)

    #NOTICE: we use all observations (including unidentified) only here
    @day_by_obs = observations_filtered.joins(:card).select('observ_date, COUNT(observations.id) as count_obs').
                  group('observ_date').
                  order('count_obs DESC, observ_date ASC').limit(10)

    @day_by_species = identified_observations.select('observ_date, COUNT(DISTINCT species_id) as count_species').
        group('observ_date').
        order('count_species DESC, observ_date ASC').limit(10)

    @day_and_loc_by_species = identified_observations.select('observ_date, locus_id, COUNT(DISTINCT species_id) as count_species').
        group('observ_date, locus_id').
        order('count_species DESC, observ_date ASC').limit(10)

    @day_by_new_species = lifelist_filtered.
        except(:select).select('first_seen, COUNT(species_id) as count_species').
        group('first_seen').except(:order).
        order('count_species DESC, first_seen ASC').limit(10)


  end

  def voices
    voiceful = "select species_id, COUNT(id) as voicenum from observations where voice group by species_id"
    total = "select species_id, count(id) as totalnum from observations group by species_id"
    @species = Species.find_by_sql("WITH voiceful AS (#{voiceful}), total AS (#{total})
                SELECT species.*, 100.00 * voicenum / totalnum as percentage
                FROM voiceful NATURAL JOIN total JOIN species on species_id = species.id
                WHERE voicenum <> 0
                ORDER BY percentage DESC
                LIMIT 20")
  end

end
