class LifelistController < ApplicationController

  def default
    @species = Species.lifelist(:year => params[:year]).all
    @years = Observation.years
  end

  def by_count
    @species = Species.lifelist(:sort => 'count', :year => params[:year]).all
    @years = Observation.years
  end

  def by_taxonomy
    @species = Species.lifelist(:sort => 'class', :year => params[:year]).all
    @years = Observation.years
  end
end