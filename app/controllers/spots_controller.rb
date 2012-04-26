class SpotsController < ApplicationController
  respond_to :json

  administrative except: :index

  # GET "/map/spots.json"
  def index
    respond_with(Spot.public, :only => [:lat, :lng])
  end

  # GET "/map/spots/search.json"
  def search
    spots =
        if params[:q] && params[:q].values.uniq != ['']
          Spot.
              joins(:observation).
              merge(Observation.search(params[:q]).result)
        else
          []
        end
    respond_with spots
  end

  # POST "/spots/save.json"
  def save
    spot = Spot.find_or_initialize_by_id(params[:spot][:id])
    spot.update_attributes!(params[:spot])
    respond_with spot
  end

  # DELETE /spots/1.json
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    respond_with @spot
  end
end