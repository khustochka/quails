class MapController < ApplicationController
  respond_to :html, :only => [:index, :edit]
  respond_to :json, :only => [:spots, :search, :savespot]

  administrative :except => [:show]

  # GET "/map"
  def show

  end

  # GET "/map/edit"
  def edit
    @search = Observation.search(params[:q])
  end

  # GET "/map/spots.json"
  def spots
    respond_with(Spot.public, :only => [:lat, :lng])
  end

  # GET "/map/search.json"
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

  # POST "/map/spots.json"
  def savespot
    spot = Spot.find_or_initialize_by_id(params[:spot][:id])
    spot.update_attributes!(params[:spot])
    respond_with spot
  end
end