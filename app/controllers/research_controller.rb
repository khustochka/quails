class ResearchController < ApplicationController

  require_http_auth

  layout 'admin'

  def index
  end

  def more_than_year
    sort_col = params[:sort].try(:to_sym) || :date2
    period = params[:period].try(:to_i) || 365
    @list = Species.includes(:observations).inject([]) do |collection, sp|
      obs = sp.observations.each_cons(2).select do |ob1, ob2|
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

  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]

    @lifelist = Species.old_lifelist(extended_params)
    raw_posts = @lifelist.map {|ob| [ob.first_post, ob.last_post]}.flatten.uniq.compact
    @posts = Hash[SessionAwarePost().where(:id => raw_posts).map {|rec| [rec.id.to_s, rec] }]
    @years = Observation.years(extended_params)
  end
end
