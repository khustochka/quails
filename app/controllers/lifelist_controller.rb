class LifelistController < ApplicationController

  before_filter do
    @allowed_params = [:controller, :action, :year]
    @years = Observation.years
  end

  def default
    @species = Species.lifelist(:year => params[:year]).all
    @posts = current_user.available_posts.for_lifers
  end

  def by_count
    @species = Species.lifelist(:sort => 'count', :year => params[:year]).all
  end

  def by_taxonomy
    @species = Species.lifelist(:sort => 'class', :year => params[:year]).all
  end
end