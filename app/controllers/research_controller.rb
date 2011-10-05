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
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @lifelist = Lifelist.new(
        user: current_user,
        options: {
            sort: params[:sort],
            year: params[:year],
            month: params[:month],
            locus: params[:locus]
        }
    )
  end
end
