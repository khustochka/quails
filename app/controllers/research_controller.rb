class ResearchController < ApplicationController

  administrative

  def index
  end

  def lifelist
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @lifelist = Lifelist.advanced.
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus)).
        preload(posts: current_user.available_posts)
  end

  def more_than_year
    sort_col = params[:sort].try(:to_sym) || :date2
    period = params[:period].try(:to_i) || 365
    @list = MyObservation.order(:observ_date).preload(:species).group_by(&:species).each_with_object([]) do |obsdata, collection|
      sp, obss = obsdata
      obs = obss.each_cons(2).select do |ob1, ob2|
        (ob2.observ_date - ob1.observ_date) >= period
      end
      collection.concat(
          obs.map do |ob1, ob2|
            {:sp => sp,
             :date1 => ob1.observ_date,
             :date2 => ob2.observ_date,
             :days => (ob2.observ_date - ob1.observ_date).to_i}
          end
      )
    end.sort { |a, b| b[sort_col] <=> a[sort_col] }
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
        group_by {|i| i.species.first}.each_with_object([]) do |imgdata, collection|

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
        where("to_char(observ_date, 'MM-DD') < '#{@month}-#{@day}'").
        where("mine").order("to_char(observ_date, 'MM-DD') DESC").limit(1).first
    @prev_day = [prev_day[:imon], prev_day[:iday]].join('-') rescue nil
    next_day = Image.joins(:observations).select("to_char(observ_date, 'DD') as iday, to_char(observ_date, 'MM') as imon").
        where("to_char(observ_date, 'MM-DD') > '#{@month}-#{@day}'").
        where("mine").order("to_char(observ_date, 'MM-DD') ASC").limit(1).first
    @next_day = [next_day[:imon], next_day[:iday]].join('-') rescue nil
    @images = Image.joins(:observations).where("mine").
        where('EXTRACT(day from observ_date) = ? AND EXTRACT(month from observ_date) = ?', @day, @month)
  end
end
