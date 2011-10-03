class LifelistController < ApplicationController

  before_filter do
    @allowed_params = [:controller, :action, :year]
  end

  def default
    lifelist = Lifelist.new(:user => current_user, :options => params)
    @lifers = lifelist.generate
    @years = lifelist.observation_years
  end

  def by_count
    lifelist = Lifelist.new(:user => current_user, :options => params.merge(:sort => 'count'))
    @lifers = lifelist.generate
    @years = lifelist.observation_years
  end

  def by_taxonomy
    lifelist = Lifelist.new(:user => current_user, :options => params.merge(:sort => 'class'))
    @lifers = lifelist.generate
    @years = lifelist.observation_years
  end
end