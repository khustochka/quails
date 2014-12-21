class SpotsController < ApplicationController

  administrative except: %i(index media)

  # FIXME: probably unused
  # GET "/map/spots.json"
  def index
    render json: Spot.public_spots, only: [:lat, :lng]
  end

  # GET "/map/media.json"
  def media
    render json: Media.for_the_map
  end

  # POST "/spots/save.json"
  def save
    spot = Spot.find_or_initialize_by(id: params[:spot][:id])
    spot.update_attributes!(params[:spot])
    render json: spot
  end

  # DELETE /spots/1.json
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    render json: {}
  end
end
