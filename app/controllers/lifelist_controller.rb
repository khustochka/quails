class LifelistController < ApplicationController

  def default
    @allowed_params = [:controller, :action, :year, :locus, :sort]

    sort_override, template =
        case params[:sort]
          when nil
            [nil, :default]
          when 'by_count'
            ['count', :by_count]
          when 'by_taxonomy'
            ['class', :by_taxonomy]
        end

    @lifelist = Lifelist.new(:user => current_user, :options => params.merge(:sort => sort_override))

    render template
  end
end