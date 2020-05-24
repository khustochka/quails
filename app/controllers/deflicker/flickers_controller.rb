module Deflicker
  class FlickersController < ApplicationController

    administrative

    def index
      @photos = Flicker.order_by(:uploaded_at => :asc).page(params[:page]).per(10)
    end

    def refresh
      FlickrLoadJob.perform_later
      redirect_to deflicker_path
    end

  end
end
