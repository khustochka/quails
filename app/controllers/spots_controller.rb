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
        Image.connection.select_rows(
            Image.select("spots.lat, spots.lng, loci.lat, loci.lon, images.id").
                joins(:cards => :locus).
                joins("LEFT OUTER JOIN (#{Spot.public.to_sql}) as spots ON spots.id=images.spot_id").
                uniq.
                to_sql
        ).
            each_with_object({}) do |e, memo|
              key = [((e[0] || e[2]).to_f * 1000).ceil / 1000.0, ((e[1] || e[3]).to_f * 1000).ceil / 1000.0]
              (memo[key.join(',')] ||= []).push(e[4].to_i)
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
