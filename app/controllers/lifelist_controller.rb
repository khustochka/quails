class LifelistController < ApplicationController

  before_filter do
    @allowed_params = [:controller, :action, :year]
    @years = Observation.years
  end

  def default
    @lifers = Lifelist.generate(:year => params[:year])
  end

  def by_count
    @lifers = Lifelist.generate(:sort => 'count', :year => params[:year])
  end

  def by_taxonomy
    @lifers = Lifelist.generate(:sort => 'class', :year => params[:year])
  end
end