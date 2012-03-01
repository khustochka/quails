class MapController < ApplicationController
  respond_to :html, :only => [:index, :edit]
  respond_to :json, :only => [:spots, :search]

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
          Observation.search(params[:q]).result.joins(:spots).select('lat, lng')
        else
          []
        end
    respond_with(spots)
  end
end