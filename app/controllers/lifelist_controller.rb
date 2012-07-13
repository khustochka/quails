class LifelistController < ApplicationController

  #caches_action :default,
  #              :cache_path => ->(c){ params.slice(:sort, :year, :locus).merge(admin: current_user.admin?) }

  def default
    @allowed_params = [:controller, :action, :year, :locus, :sort]

    sort_override =
        case params[:sort]
          when nil
            nil
          when 'by_taxonomy'
            'class'
          else
            raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
        end

    @lifelist = Lifelist.basic.
        sort(sort_override).
        filter(params.slice(:year, :locus)).
        preload(posts: current_user.available_posts)
  end

  def advanced
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @lifelist = Lifelist.advanced.
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus)).
        preload(posts: current_user.available_posts)
  end
end
