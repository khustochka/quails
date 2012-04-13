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
        strategy: Lifelist::BasicStrategy.new(sort: sort_override),
        user: current_user,
        filter: params.slice(:year, :locus)
    )
  end
end