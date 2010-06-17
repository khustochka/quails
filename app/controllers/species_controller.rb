class SpeciesController < ApplicationController

  before_filter :find_species, :except => :index

#  helper_method :latin_url_humanize

  # GET /species
  # GET /species.xml
  def index
    @page_title = 'Listing species'
    @species = Species.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @species }
    end
  end

  # GET /species/1
  # GET /species/1.xml
  def show
    @page_title = "#{@species.name_sci} / #{@species.name_en}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @species }
    end
  end

  # GET /species/1/edit
  def edit
    @page_title = "Editing #{@species.name_sci} / #{@species.name_en}"
  end

  # PUT /species/1
  # PUT /species/1.xml
  def update

    respond_to do |format|
      if @species.update_attributes(params[:species])
        format.html { redirect_to(@species, :notice => 'Species was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @species.errors, :status => :unprocessable_entity }
      end
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
