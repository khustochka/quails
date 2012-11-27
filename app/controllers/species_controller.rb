class SpeciesController < ApplicationController

  administrative :except => [:index, :show]

  before_filter :find_species, only: [:edit, :update]

  # GET /species
  def index
    @species = Species.ordered_by_taxonomy.extend(SpeciesArray)
  end

  # GET /species/1
  def show
    id_humanized = params[:id].sp_humanize
    @species = Species.find_by_name_sci(id_humanized) || Taxon.find_by_name_sci!(id_humanized).species
    if @species
      if params[:id] != @species.to_param
        #redirect_to @species, :status => 301
        # TODO: set canonical, set NOCACHE, NOINDEX
      end
    else
      raise ActiveRecord::RecordNotFound, "Cannot find #{id_humanized}"
    end
  end

  # GET /species/1/edit
  def edit
    render :form
  end

  # PUT /species/1
  def update
    params[:species].delete(:code) if params[:species][:code].blank?
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
