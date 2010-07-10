class LifelistController < ApplicationController
  # GET /lifelist
  # GET /lifelist.xml
  def show
    obs = Observation.mine.select(:species_id, 'MIN(observ_date) AS mind').group(:species_id)
    @species = Species.select('*').joins("INNER JOIN (#{obs.to_sql}) AS obs ON species.id=obs.species_id").reorder('mind DESC, index_num DESC').all
#     @species = Species.select('DISTINCT species.*, observ_date').joins(:first_observation).reorder('observ_date DESC').all

    respond_to do |format|
      format.html
      format.xml { render :xml => @species }
    end
  end

end
