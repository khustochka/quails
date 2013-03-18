class ResearchController < ApplicationController

  administrative

  def environ
    #@env = ENV
  end

  def index
  end

  def more_than_year
    if params[:days]
      sort_col = params[:sort].try(:to_sym) || :date2
      @period = params[:days].to_i
      query = MyObservation.select("species_id, observ_date").order(:observ_date).to_sql
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

    long_rel = MyObservation.joins(:images).select("species_id, MAX(observ_date) as lastphoto").
        group(:species_id).having("MAX(observ_date) < (now() - interval '2 years')")

    @long_time = Species.select('*').
        joins("INNER JOIN (#{long_rel.to_sql}) AS obs ON species.id=obs.species_id").order('lastphoto')


    sort_col = :date2
    period = 365 * 2 * 24 * 60 * 60
    @recent_2yrs = Image.joins(:observations).order(:created_at).preload(:species).merge(MyObservation.scoped).
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
    prev_day = Image.joins(:observations).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
        where("to_char(observ_date, 'MM-DD') < '#@month-#@day'").
        where("mine").order("to_char(observ_date, 'MM-DD') DESC").limit(1).first
    @prev_day = [prev_day[:imon], prev_day[:iday]].join('-') rescue nil
    next_day = Image.joins(:observations).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
        where("to_char(observ_date, 'MM-DD') > '#@month-#@day'").
        where("mine").order("to_char(observ_date, 'MM-DD') ASC").limit(1).first
    @next_day = [next_day[:imon], next_day[:iday]].join('-') rescue nil
    @images = Image.joins(:observations).where("mine").
        where('EXTRACT(day from observ_date) = ? AND EXTRACT(month from observ_date) = ?', @day, @month)
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
    @uptoday = MyObservation.where(
        'EXTRACT(month FROM observ_date) < ? OR
        (EXTRACT(month FROM observ_date) = ?
        AND EXTRACT(day FROM observ_date) <= ?)',
        @this_day.month, @this_day.month, @this_day.day
    ).
        order('EXTRACT(year FROM observ_date)').
        group('EXTRACT(year FROM observ_date)').
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
                              MyObservation.where(locus_id: @loc1.country.subregion_ids)
                            else
                              MyObservation.scoped
                            end

      @species = Species.uniq.joins(:observations).merge(observations_source).ordered_by_taxonomy.extend(SpeciesArray)

      @loc1_species = Species.uniq.joins(:observations).merge(MyObservation.where(locus_id: @loc1.subregion_ids)).all
      @loc2_species = Species.uniq.joins(:observations).merge(MyObservation.where(locus_id: @loc2.subregion_ids)).all
    else
      l1 ||= 'kiev'
      l2 ||= 'brovary'
      redirect_to(loc1: l1, loc2: l2)
    end
  end

  def stats
    @year_data = MyObservation.select('EXTRACT(year FROM observ_date) as year,
                                      COUNT(id) as count_obs,
                                      COUNT(DISTINCT observ_date) as count_days,
                                      COUNT(DISTINCT species_id) as count_species').
                group('EXTRACT(year FROM observ_date)').order(:year)
    @first_sp_by_year = Lifelist.basic.relation.group('EXTRACT(year FROM first_seen)').except(:order).count

    @month_data = MyObservation.select('EXTRACT(month FROM observ_date) as month,
                                      COUNT(id) as count_obs,
                                      COUNT(DISTINCT species_id) as count_species').
        group('EXTRACT(month FROM observ_date)').order(:month)
    @first_sp_by_month = Lifelist.basic.relation.group('EXTRACT(month FROM first_seen)').except(:order).count
  end

end
