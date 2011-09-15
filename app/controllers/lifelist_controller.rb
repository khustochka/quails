class LifelistController < ApplicationController

  def default
    @species = Species.lifelist.all
  end

  def by_count
    @species = Species.lifelist(:sort => 'count').all
  end

  def by_taxonomy
    @species = Species.lifelist(:sort => 'class').all
  end
end