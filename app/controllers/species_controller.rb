class SpeciesController < PublicController
  # GET /species
  # GET /species.xml
  def index
    @species = Species.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @species }
    end
  end

  # GET /species/1
  # GET /species/1.xml
  def show
    @species = Species.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @species }
    end
  end

  # GET /species/1/edit
  def edit
    @species = Species.find(params[:id])
  end

  # PUT /species/1
  # PUT /species/1.xml
  def update
    @species = Species.find(params[:id])

    respond_to do |format|
      if @species.update_attributes(params[:species])
        format.html { redirect_to(@species, :notice => 'Species was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @species.errors, :status => :unprocessable_entity }
      end
    end
  end
end
