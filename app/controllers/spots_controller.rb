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
              joins("JOIN (#{Observation.search(params[:q]).result.to_sql}) as obs ON observation_id=obs.id").
              select('lat, lng')
        else
          []
        end
    respond_with(spots)
  end

  # POST /spots.json
  def create
    @spot = Spot.new(params[:spot])
    @spot.save

    respond_with @spot
  end

  # PUT /spots/1.json
  def update
    @spot = Spot.find(params[:id])
    @spot.update_attributes(params[:spot])

    respond_with @spot
  end

  # DELETE /spots/1.json
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    respond_with @spot
  end
end