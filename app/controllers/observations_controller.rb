class ObservationsController < ApplicationController

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
    render :json => (Observation.search(params[:q]).result.preload(:locus, :species).limit(10).map do |ob|
      {:id => ob.id, :loc => ob.locus.name_en, :sp => ob.species.name_sci, :date => ob.observ_date}
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
    common = params[:c]
    test_obs = Observation.new({:species_id => 0}.merge(common))
    test_obs.valid?
    errors_collection = test_obs.errors
    errors_collection.add(:base, 'provide at least one observation') if params[:o].blank?
    if errors_collection.empty?
      saved_obs = params[:o].map do |obs|
        obs_data = obs.merge(common)
        observation = obs[:id] ?
            Observation.update(obs[:id], obs_data) :
            Observation.create(obs_data)
        observation.errors.empty? ? {:id => observation.id} : {:msg => observation.errors}
      end
      render :json => {:result => 'OK', :data => saved_obs}
    else
      render :json => {:result => 'Error', :data => errors_collection}
    end
  end
end
