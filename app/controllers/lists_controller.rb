class ListsController < ApplicationController

  CURRENT_YEAR = 2016

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
    allow_params(:year, :locus, :sort)

    sort_override =
        case params[:sort]
          when nil
            nil
          when 'by_taxonomy'
            'class'
          else
            raise ActionController::RoutingError, "Illegal argument sort=#{params[:sort]}"
        end

    locus = params[:locus]
    @locations = Country.all

    raise ActiveRecord::RecordNotFound if locus && !locus.in?(@locations.map(&:slug))

    @lifelist = NewLifelist.
        over(params.slice(:year, :locus)).
        sort(sort_override)

    if I18n.russian_locale?
      @lifelist.set_posts_scope(current_user.available_posts)
    end
  end

  def advanced
    allow_params(:year, :locus, :sort, :month)

    @locations = Locus.locs_for_lifelist

    sources = {loci: current_user.available_loci}

    sources[:posts] = current_user.available_posts if I18n.russian_locale?

    @lifelist = Lifelist.advanced.
        source(sources).
        sort(params[:sort]).
        filter(params.slice(:year, :month, :locus))
  end
end
