class MapController < ApplicationController
  respond_to :html, :only => [:index, :edit]
  respond_to :json, :only => [:spots]

  administrative :except => [:show]

  # GET "/map"
  def show

  end

  # GET "/map/edit"
  def edit
    @search = Observation.search(params[:q])
    @observations = if params[:q] && params[:q].values.uniq != ['']
                      @search.result.preload(:locus, :species)
                    else
                      []
                    end
  end

  # GET "/map/spots.json"
  def spots
    respond_with(Spot.public, :only => [:lat, :lng])
  end
end