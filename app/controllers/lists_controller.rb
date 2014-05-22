class ListsController < ApplicationController

  def index
    @top_5_life = Lifelist.basic.relation.limit(5)
    @top_5_year = Lifelist.basic.filter(year: 2014).relation.limit(5)

    @list_prev_year = Lifelist.basic.filter(year: 2013).relation

    @list_ukraine = Lifelist.basic.filter(locus: 'ukraine').relation

    @list_usa = Lifelist.basic.filter(locus: 'usa').relation
    @list_uk = Lifelist.basic.filter(locus: 'united_kingdom').relation
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

    sources = I18n.russian_locale? ? {posts: current_user.available_posts} : {}

    @lifelist = Lifelist.basic.
        source(sources).
        sort(sort_override).
        filter(params.slice(:year, :locus))
  end

  def advanced
    @allowed_params = [:controller, :action, :year, :locus, :sort, :month]

    @locations = Locus.locs_for_lifelist

    sources = {loci: current_user.available_loci}

    sources[:posts] = current_user.available_posts if I18n.russian_locale?

    @lifelist = Lifelist.advanced.
        source(sources).
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus))
  end
end
