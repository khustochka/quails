class ListsController < ApplicationController

  def index
    @list_life = Lifelist::FirstSeen.full
    @list_current_year = Lifelist::FirstSeen.over(year: Quails::CURRENT_YEAR)

    #@list_prev_year = Lifelist::FirstSeen.over(year: Quails::CURRENT_YEAR - 1)

    @list_canada = Lifelist::FirstSeen.over(locus: 'canada')

    @list_ukraine = Lifelist::FirstSeen.over(locus: 'ukraine')

    @list_usa = Lifelist::FirstSeen.over(locus: 'usa')
    @list_uk = Lifelist::FirstSeen.over(locus: 'united_kingdom')
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

    @lifelist = Lifelist::FirstSeen.
        over(params.permit(:year, :locus)).
        sort(sort_override)

    if I18n.russian_locale?
      @lifelist.set_posts_scope(current_user.available_posts)
    end
  end

  def advanced
    allow_params(:year, :locus, :sort, :month)

    @locations = Locus.locs_for_lifelist

    locus = params[:locus]

    raise ActiveRecord::RecordNotFound if locus && !locus.in?(current_user.available_loci.map(&:slug))

    @lifelist = Lifelist::Advanced.
        over(params.permit(:year, :month, :locus)).
        sort(params[:sort])

    if I18n.russian_locale?
      @lifelist.set_posts_scope(current_user.available_posts)
    end

  end
end
