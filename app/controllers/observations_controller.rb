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
    respond_with(observs, :only => :id, :methods => [:species_str, :when_where_str])
  end

  # GET /observations/1
  def show
    redirect_to :action => :edit, :id => params[:id]
  end

  # GET /observations/new
  # Adding single observation
  def new
    @observation = Observation.new({:post_id => params[:post_id]})
    render :form
  end

  # GET /observations/add
  # Adding multiple observations
  def add
    @observations = [Observation.new]
    @blogpost = Post.find_by_id(params[:post_id]) if params[:post_id]
    render :bulk
  end

  # GET /observations/1/edit
  def edit
    render :form
  end

  # GET /observations/bulk
  # Bulk edit observations
  def bulk
    if (l = params[:locus_id]) && (d = params[:observ_date]) && (m = params[:mine])
      @observations = Observation.where(:locus_id => l, :observ_date => d, :mine => m).all
      render
    else
      redirect_to add_observations_url(:locus_id => l, :observ_date => d, :mine => m)
    end
  end

  # POST /observations
  def create
    @observation = Observation.new(params[:c].merge(params[:o].first))

    if @observation.save
      redirect_to(@observation, :notice => 'Observation was successfully created.')
    else
      render :form
    end
  end

  # PUT /observations/1
  def update
    params[:c][:post_id] ||= nil
    if @observation.update_attributes(params[:c].merge(params[:o].first))
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

  # POST /observations/bulksave
  # API: parameters are a hash with two keys:
  # c: hash of common options - locus_id, observ_date,mine, post_id
  # o: array of hashes each having species_id, quantity, biotope, place, notes
  def bulksave
    obs_bunch = ObservationBulk.new(params)
    obs_bunch.save
    respond_with(obs_bunch, :location => observations_url, :only => :id)
  end
end