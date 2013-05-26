class MapsController < ApplicationController
  respond_to :html, :only => [:index, :edit]

  administrative :except => [:show]

  # GET "/map"
  def show

  end

  # GET "/map/edit"
  def edit
    @search = ObservationSearch.new(params[:q])
    @spot = Spot.new(public: true)
  end

end
