class SpeciesController < ApplicationController

  layout 'admin', :except => [:index, :show, :lifelist]
  layout 'public', :only => [:index, :show, :lifelist]

  before_filter :find_species, :only => [:show, :edit, :update]

  # GET /species
  def index
    @species  = Species.all
    @families = @species.map { |sp|
      {:name => sp.family, :order => sp.order}
    }.uniq.map { |fam|
      fam.merge(:species => @species.select { |s| s.family == fam[:name] })
    }
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

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.get_subregions(Locus.select(:id).find_by_code!(params[:locus]))) if params[:locus]
    @species        = Species.lifelist(extended_params).all
    @years          = ([{:year => nil}] + Observation.years(extended_params)).map { |ob| ob[:year] }

    respond_to do |format|
      format.html
      format.xml { render :xml => @species }
    end
  end

  private
  # TODO: investigate why problems in update when trying to save invalid name_sci
  def find_species
    @species = Species.find_by_name_sci!(latin_url_humanize(params[:id]))
  end

  def latin_url_humanize(sp_url)
    sp_url.gsub(/_|\+/, ' ').gsub(/ +/, ' ').capitalize
  end
end
