class ListsController < ApplicationController

  def index
    @top_5_life = Lifelist.basic.relation.limit(5)
    @top_5_year = Lifelist.basic.filter(year: 2013).relation.limit(5)
    #@top_5_ukraine = Lifelist.basic.filter(locus: 'ukraine').relation.limit(5)
    @top_5_usa = Lifelist.basic.filter(locus: 'usa').relation.limit(5)
  end

  def basic

    @allowed_params = [:controller, :action, :year, :locus, :sort]

    sort_override =
        case params[:sort]
          when nil
            nil
          when 'by_taxonomy'
            'class'
          else
            raise ActionController::RoutingError, "Illegal argument sort=#{params[:sort]}"
        end

    @locations = Country.all

    @lifelist = Lifelist.basic.
        source(posts: current_user.available_posts).
        sort(sort_override).
        filter(params.slice(:year, :locus))
  end

  def advanced
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @locations = Locus.public

    @lifelist = Lifelist.advanced.
        source(loci: current_user.available_loci, posts: current_user.available_posts).
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus))
  end
end
