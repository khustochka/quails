class MapController < ApplicationController
  respond_to :html, :only => [:index]
  respond_to :json, :only => [:spots]

  requires_admin_authorized

  layout 'public'

  # GET "/map"
  def index

  end

  # GET "/map/spots.json"
  def spots
    respond_with(Spot.public, :only => [:lat, :lng])
  end
end