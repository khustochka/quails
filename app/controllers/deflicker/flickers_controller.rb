module Deflicker
  class FlickersController < ApplicationController

    administrative

    def index
      @photos = Flicker.page(params[:page])
    end

    def refresh
      FlickrLoadJob.perform_later
      redirect_to deflicker_path
    end

  end
end
