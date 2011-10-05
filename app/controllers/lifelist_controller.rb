class LifelistController < ApplicationController

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

    @lifelist = Lifelist.new(:user => current_user, :options => params.merge(:sort => sort_override))
  end
end