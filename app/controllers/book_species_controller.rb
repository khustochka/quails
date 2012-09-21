class BookSpeciesController < ApplicationController

  administrative

  before_filter :find_species, :only => [:show, :edit, :update]

  # GET /species
  def index
    @authority = Authority.find_by_slug(params[:authority_id])
    @species = @authority.book_species.extend(SpeciesArray)
  end

  # GET /species/1
  def show
  end

  # GET /species/1/edit
  def edit
    render :form
  end

  # PUT /species/1
  def update
    if @species.update_attributes(params[:species])
      redirect_to(@species, :notice => 'BookSpecies was successfully updated.')
    else
      render :form
    end
  end

  private
  def find_species
    @authority = Authority.find_by_slug(params[:authority_id])
    @species = BookSpecies.find_by_name_sci!(params[:id].sp_humanize)
  end
end
