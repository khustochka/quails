class SpotsController < ApplicationController
  respond_to :json

  administrative except: %i(index photos)

  # GET "/map/spots.json"
  def index
    respond_with(Spot.public, :only => [:lat, :lng])
  end

  # GET "/map/photos.json"
  def photos
    respond_with(
        Spot.public.select("lat, lng, images.id as data").joins(:images),
        :only => [:lat, :lng, :data]
    )
  end

  # POST "/spots/save.json"
  def save
    spot = Spot.find_or_initialize_by(id: params[:spot][:id])
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
