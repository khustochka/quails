# frozen_string_literal: true

class LegacySpeciesController < ApplicationController

  administrative

  before_action :find_species, only: [:show]

  # GET /species/admin
  def index
    @species = LegacySpecies.ordered_by_taxonomy.extend(SpeciesArray)
  end

  def show
    render :form
  end

  private
  def find_species
    @species = LegacySpecies.find_by!(name_sci: LegacySpecies.humanize(params[:id]))
  end
end
