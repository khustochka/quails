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
          # Though you may think of Spots.search(params[:q])... it only works if query is like
          # {observation_observ_date: '2011-01-01'} which is problematic for reusing observattions/search partial.
          # And benchmarking shows it is just a small bit slower.
          Observation.search(params[:q]).result.joins(:spots).select('lat, lng')
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