class ListsController < ApplicationController

  def index
    @top_5_life = Lifelist.simple.limit(5)
    @top_5_year = Lifelist.simple.filter(year: 2014).limit(5)

    #@list_prev_year = Lifelist.simple.filter(year: 2013)
    @list_canada = Lifelist.simple.filter(locus: 'canada')

    @list_ukraine = Lifelist.simple.filter(locus: 'ukraine')

    @list_usa = Lifelist.simple.filter(locus: 'usa')
    @list_uk = Lifelist.simple.filter(locus: 'united_kingdom')
  end

  def simple

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

    @lifelist = Lifelist.simple.
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
