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

    @locations = Locus.countries.group_by(&:slug)

    @lifelist = Lifelist.basic.
        source(posts: current_user.available_posts).
        sort(sort_override).
        filter(params.slice(:year, :locus))
  end

  def advanced
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @locations = current_user.available_loci.group_by(&:slug)

    @lifelist = Lifelist.advanced.
        source(loci: current_user.available_loci, posts: current_user.available_posts).
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus))
  end
end
