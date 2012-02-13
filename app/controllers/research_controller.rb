class ResearchController < ApplicationController

  administrative

  def index
  end

  def more_than_year
    sort_col = params[:sort].try(:to_sym) || :date2
    period = params[:period].try(:to_i) || 365
    @list = Observation.mine.identified.preload(:species).group_by(&:species).inject([]) do |collection, obsdata|
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

  def unpictured
    @list = Species.select('name_sci, name_en, COUNT(observations.id) AS cnt').joins(:observations).
        where(
              "species_id NOT IN (%s)" % 
              Observation.select('DISTINCT species_id').
                  joins('INNER JOIN images_observations as im on (observations.id = im.observation_id)').to_sql
              ).group(:name_sci, :name_en).reorder('cnt DESC')
  end

  def lifelist
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @lifelist = Lifelist.new(
        user: current_user,
        format: :advanced,
        options: {
            sort: params[:sort],
            year: params[:year],
            month: params[:month],
            locus: params[:locus]
        }
    )
  end

  def day
    @month, @day = (params[:day].try(:split, '-') || [Time.now.month, Time.now.day]).map {|n| "%02d" % n.to_i}
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
