class LifelistController < ApplicationController

  def default
    @species = Species.lifelist.all
  end

  def count
    @species = Species.lifelist(:sort => 'count').all
  end

  def taxonomy
    @species = Species.lifelist(:sort => 'class').all
  end
end