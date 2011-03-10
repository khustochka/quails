class ObservationsController < ApplicationController

  require_http_auth

  layout 'admin'

  use_jquery :only => [:index, :new, :create]
  javascript 'jquery-ui-1.8.10.custom.min', 'species_select', :only => [:new, :create]
  stylesheet 'autocomplete', :only => [:new, :create]

  add_finder_by :id, :only => [:edit, :update, :destroy]

  # GET /observations
  def index
    @observations = Observation.order(params[:sort]).preload(:species, :locus, :post).page(params[:page])
  end

  # GET /observations/1
  def show
    redirect_to :action => :edit, :id => params[:id]
  end

  # GET /observations/new
  def new
    @observation = Observation.new
    render :form
  end

  # GET /observations/1/edit
  def edit
    render :form
  end

  # POST /observations
  def create
    @observation = Observation.new(params[:observation])

    if @observation.save
      redirect_to(@observation, :notice => 'Observation was successfully created.')
    else
      render :form
    end
  end

  # PUT /observations/1
  def update
    if @observation.update_attributes(params[:observation])
      redirect_to(edit_observation_path(@observation), :notice => 'Observation was successfully updated.')
    else
      render :form
    end
  end

  # DELETE /observations/1
  def destroy
    @observation.destroy
    redirect_to(observations_url)
  end

end
