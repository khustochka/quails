module Deflicker
  class FlickersController < ApplicationController

    administrative

    def index
      @search = Deflicker::Search.new(search_params)
      @photos = @search.result.order_by(:uploaded_at => :asc).page(params[:page]).per(10)
    end

    def refresh
      FlickrLoadJob.perform_later
      redirect_to deflicker_path
    end

    def rematch
      SiteMatchJob.perform_later
      redirect_to deflicker_path
    end

    private

    def search_params
      params.slice(*Deflicker::Search.attribute_names)
    end

  end
end
