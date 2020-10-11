# frozen_string_literal: true

class SpuhsController < ApplicationController

  administrative

  before_action do
    @light_species_selector = true
  end

  def index
    find_data
  end

  def show
    find_data
    render partial: "spuhs/spuh"
  end

  def update
    find_data
    if @observation.update!(params[:observation])
      redirect_to spuh_path(@next.id)
    end
  end

  private

  def find_data
    @observation = if params[:id]
                     Observation.find(params[:id])
                   else
                     spuhs_obs.first
                   end
    @next = spuhs_obs.where("id > ?", @observation.id).first
  end

  def spuhs_obs
    Observation.where(taxon: bird_sp).order(:id)
  end

  def bird_sp
    Taxon.find_by_ebird_code("bird1")
  end

end
