class SpotsController < ApplicationController
  respond_to :json

  administrative

    # GET "/map/spots.json"
  def index
    respond_with(Spot.public, :only => [:lat, :lng])
  end

  # GET "/map/spots/search.json"
  def search
    spots =
        if params[:q] && params[:q].values.uniq != ['']
          Spot.
              joins("JOIN (#{Observation.search(params[:q]).result.to_sql}) as obs ON observation_id=obs.id").
              select('lat, lng')
        else
          []
        end
    respond_with(spots)
  end

  # POST "/map/spots/save.json"
  def save
    spot = Spot.find_or_initialize_by_id(params[:spot][:id])
    spot.update_attributes!(params[:spot])
    respond_with spot
  end
end