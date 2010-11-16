class SpeciesController < ApplicationController

  layout 'admin', :except => [:index, :show, :lifelist]
  layout 'public', :only => [:index, :show, :lifelist]

  before_filter :find_species, :only => [:show, :edit, :update]

  # GET /species
  # GET /species.xml
  def index
    @species = Species.all
    @families = @species.map { |sp|
      {:name => sp.family, :order => sp.order}
    }.uniq.map { |fam|
      fam.merge(:species => @species.select { |s| s.family == fam[:name] })
    }

    respond_to do |format|
      format.html # index.html.erb
      # format.xml { render :xml => @species }
    end
  end

  # GET /species/1
  # GET /species/1.xml
  def show
    if params[:id] != @species.to_param
      redirect_to @species
    else
      respond_to do |format|
        format.html # show.html.erb
        # format.xml { render :xml => @species }
      end
    end
  end

  # GET /species/1/edit
  def edit
    respond_to do |format|
      format.html { render :form }
    end
  end

  # PUT /species/1
  # PUT /species/1.xml
  def update

    respond_to do |format|
      if @species.update_attributes(params[:species])
        format.html { redirect_to(@species, :notice => 'Species was successfully updated.') }
        # format.xml { head :ok }
      else
        format.html { render :form }
        # format.xml { render :xml => @species.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    new_params = params.merge(:loc_ids => Locus.get_subregions(Locus.find_by_code(params[:locus])))
    @species = Species.lifelist(new_params).all
    @years = ([{:year => nil}] + Observation.years(new_params)).map {|ob| ob[:year]}
    
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
