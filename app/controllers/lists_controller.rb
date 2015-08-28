class ListsController < ApplicationController

  CURRENT_YEAR = 2015

  def index
    @list_life = BasicLifelist.full
    @list_current_year = BasicLifelist.over(year: CURRENT_YEAR)

    #@list_prev_year = BasicLifelist.over(year: CURRENT_YEAR - 1)

    @list_canada = BasicLifelist.over(locus: 'canada')

    @list_ukraine = BasicLifelist.over(locus: 'ukraine')

    @list_usa = BasicLifelist.over(locus: 'usa')
    @list_uk = BasicLifelist.over(locus: 'united_kingdom')
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
