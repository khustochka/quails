class LifelistController < ApplicationController

  #caches_action :default,
  #              :cache_path => ->(c){ params.slice(:sort, :year, :locus).merge(admin: current_user.admin?) }

  def default
    @allowed_params = [:controller, :action, :year, :locus, :sort]

    sort_override =
        case params[:sort]
          when nil
            nil
          when 'by_count'
            'count'
          when 'by_taxonomy'
            'class'
        end

    @lifelist = Lifelist.new(
        user: current_user,
        options: {
            sort: sort_override,
            year: params[:year],
            locus: params[:locus]
        }
    )
  end
end