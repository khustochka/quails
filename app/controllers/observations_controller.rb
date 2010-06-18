class ObservationsController < ApplicationController
  # GET /observations
  # GET /observations.xml
  def index
    @observations = Observation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @observations }
    end
  end

  # GET /observations/1
  # GET /observations/1.xml
  def show
    @observation = Observation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @observation }
    end
  end

  # GET /observations/new
  # GET /observations/new.xml
  def new
    @observation = Observation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @observation }
    end
  end

  # GET /observations/1/edit
  def edit
    @observation = Observation.find(params[:id])
  end

  # POST /observations
  # POST /observations.xml
  def create
    @observation = Observation.new(params[:observation])

    respond_to do |format|
      if @observation.save
        format.html { redirect_to(@observation, :notice => 'Observation was successfully created.') }
        format.xml  { render :xml => @observation, :status => :created, :location => @observation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @observation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /observations/1
  # PUT /observations/1.xml
  def update
    @observation = Observation.find(params[:id])

    respond_to do |format|
      if @observation.update_attributes(params[:observation])
        format.html { redirect_to(@observation, :notice => 'Observation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @observation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/1
  # DELETE /observations/1.xml
  def destroy
    @observation = Observation.find(params[:id])
    @observation.destroy

    respond_to do |format|
      format.html { redirect_to(observations_url) }
      format.xml  { head :ok }
    end
  end
end
