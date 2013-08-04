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
        Spot.connection.select_rows(
            Spot.public.select("lat, lng, images.id").joins(:images).to_sql
        ).
            each_with_object({}) do |e, memo|
              key = [(e[0].to_f * 1000).ceil / 1000.0, (e[1].to_f * 1000).ceil / 1000.0]
              (memo[key.join(',')] ||= []).push(e[2].to_i)
            end
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
