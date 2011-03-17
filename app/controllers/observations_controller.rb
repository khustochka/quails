class ObservationsController < ApplicationController

  require_http_auth

  layout 'admin'

  use_jquery :except => [:show, :destroy]
  javascript 'jquery-ui-1.8.10.custom.min', 'suggest_over_combo', :except => [:show, :destroy]
  stylesheet 'autocomplete', :except => [:show, :destroy]
  stylesheet 'forms', :except => [:show, :destroy]

  add_finder_by :id, :only => [:edit, :update, :destroy]

  # GET /observations
  def index
    @search       = Observation.search(params[:search])
    search_params = params[:search].try(:dup)
    if search_params && search_params[:species_id_eq] == '0'
      search_params.delete(:species_id_eq)
      search_params[:species_id_is_null] = 'true'
    end
    real_search   = Observation.search(search_params)
    @observations = real_search.relation.order(params[:sort]).preload(:locus, :post).page(params[:page]).\
    send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)
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
