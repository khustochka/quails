# frozen_string_literal: true

class SpotsController < ApplicationController

  administrative

  # POST "/spots/save.json"
  def save
    spot = Spot.find_or_initialize_by(id: params[:spot][:id])
    spot.update!(params[:spot])
    render json: spot
  end

  # DELETE /spots/1.json
  def destroy
    @spot = Spot.find(params[:id])
    @spot.destroy

    render json: {}
  end
end
