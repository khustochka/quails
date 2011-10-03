class LifelistController < ApplicationController

  before_filter do
    @allowed_params = [:controller, :action, :year]
    @years = Observation.years
  end

  def default
    @lifers = Lifelist.new(:user => current_user, :options => params).generate
  end

  def by_count
    @lifers = Lifelist.new(:user => current_user, :options => params.merge(:sort => 'count')).generate
  end

  def by_taxonomy
    @lifers = Lifelist.new(:user => current_user, :options => params.merge(:sort => 'class')).generate
  end
end