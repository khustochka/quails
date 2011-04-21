class ObservationsController < ApplicationController

  require_http_auth

  layout 'admin'

  use_jquery :except => [:show, :destroy]
  javascript 'jquery-ui-1.8.11.custom.min', 'suggest_over_combo', :except => [:show, :destroy]
  javascript 'observations-bulk', :only => :bulkadd
  stylesheet 'autocomplete', :except => [:show, :destroy]
  stylesheet 'forms', :except => [:show, :destroy]

  add_finder_by :id, :only => [:edit, :update, :destroy]

  # GET /observations
  def index
    @search = Observation.search(params[:search])
    @observations = @search.relation.order(params[:sort]).preload(:locus, :post).page(params[:page]).\
    send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)
  end

  # GET /observations/1
  def show
    redirect_to :action => :edit, :id => params[:id]
  end

  # GET /observations/new
  def new
    @observation = Observation.new({:post_id => params[:post_id]})
    render :form
  end

  # GET /observations/bulkadd
  def bulkadd
    @observation = Observation.new({:post_id => params[:post_id]})
  end

  # GET /observations/1/edit
  def edit
    render :form
  end

  # POST /observations
  def create
    @observation = Observation.new(
        params[:c] && params[:o] ?
            params[:c].merge(params[:o].first) :
            params[:observation]
    )

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

  # POST /observations.bulksave
  # API: parameters are a hash with two keys:
  # c: hash of common options - locus_id, observ_date,mine, post_id
  # o: array of hashes each having species_id, quantity, biotope, place, notes
  def bulksave
    common = params[:c]
    test_obs = Observation.new({:species_id => 9999}.merge(common))
    if test_obs.valid?
      saved_obs = params[:o].inject([]) do |memo, obs|
        obs_data = obs.merge(common)
        observation = obs[:id] ?
            Observation.update(obs[:id], obs_data) :
            Observation.create(obs_data)
        memo.push(
            observation.errors.empty? ? {:id => observation.id} : {:msg => observation.errors}
        )
      end
      render :json => {:result => "OK", :data => saved_obs}
    else
      render :json => {:result => "Error", :data => test_obs.errors}
    end
  end
end
