class SpeciesController < ApplicationController

  check_http_auth :except => [:index, :show]

  layout 'admin', :except => [:index, :show]

  before_filter :find_species, :only => [:show, :edit, :update]

  # GET /species
  def index
    @species  = Species.all
  end

  # GET /species/1
  def show
    if params[:id] != @species.to_param
      redirect_to @species
    end
  end

  # GET /species/1/edit
  def edit
    render :form
  end

  # PUT /species/1
  def update
    if @species.update_attributes(params[:species])
      redirect_to(@species, :notice => 'Species was successfully updated.')
    else
      render :form
    end
  end

  private
  def find_species
    @species = Species.find_by_name_sci!(params[:id].sp_humanize)
  end
end
