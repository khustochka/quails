# frozen_string_literal: true

class MediaSeriesController < ApplicationController

  administrative

  def index
    @series = MediaSeries.order(:created_at).page(params[:page])
  end

end
