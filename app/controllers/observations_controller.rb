class ObservationsController < ApplicationController

  respond_to :json, :only => [:search, :bulksave]

  requires_admin_authorized

  layout 'admin'

  add_finder_by :id, :only => [:edit, :update, :destroy]

  # GET /observations
  def index
    @search = Observation.search(params[:q])
    # sorting by species.index_num requires using #includes
    # but #preload is faster, so use it for locus and post, and for species if possible
    @observations = @search.result.order(params[:sort]).preload(:locus, :post).page(params[:page]).
        send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)
  end

  # GET /observations/search
  def search
    observs =
        if params[:image_id]
          Image.find_by_id(params[:image_id]).observations.preload(:locus, :species)
        else
          Observation.search(params[:q]).result.preload(:locus, :species).limit(5)
        end
    respond_with(observs.map do |ob|
      {:id => ob.id, :sp_data => ob.obs_species_data, :obs_data => ob.obs_when_where_data}
    end)
  end

  # GET /observations/1
  def show
    redirect_to :action => :edit, :id => params[:id]
  end

  # GET /observations/new
  def new
    @observation = Observation.new({:post_id => params[:post_id]})
  end

  # GET /observations/1/edit
  def edit
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
      render :edit
    end
  end

  # PUT /observations/1
  def update
    if @observation.update_attributes(params[:observation])
      redirect_to(edit_observation_path(@observation), :notice => 'Observation was successfully updated.')
    else
      render :edit
    end
  end

  # DELETE /observations/1
  def destroy
    @observation.destroy
    redirect_to(observations_url)
  end

  # POST /observations/bulksave
  # API: parameters are a hash with two keys:
  # c: hash of common options - locus_id, observ_date,mine, post_id
  # o: array of hashes each having species_id, quantity, biotope, place, notes
  def bulksave
    obs_bunch = ObservationBulk.new(params)
    obs_bunch.save
    respond_with(obs_bunch, :location => observations_url)
  end
end