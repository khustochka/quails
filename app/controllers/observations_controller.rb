class ObservationsController < ApplicationController

  respond_to :json, :only => [:search, :bulksave, :with_spots]

  administrative

  add_finder_by :id, :only => [:edit, :update, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy, :bulksave]

  # GET /observations
  def index
    @search = Observation.search(params[:q])
    # sorting by species.index_num requires using #includes
    # but #preload is faster, so use it for locus and post, and for species if possible
    @observations = @search.result.order(params[:sort]).preload(:locus, :post).page(params[:page]).
        send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)

    @observations.extend(CommonValueSelector)
    query = params[:q] || {}
    @common = Hash.new do |hash, key|
      opt = query["#{key}_eq"]
      hash[key] =
          if opt.nil? || opt == '' # don't use opt.present? because mine=false is meaningful (not the same as mine=nil)
            @observations.if_common_value(key)
          else
            opt
          end
    end

    # need to initialize this value to form proper url to bulk edit (for only the selected species)
    @common[:species_id] = query[:species_id_eq] unless query[:species_id_eq].empty?
  end

  # GET /observations/search
  def search
    observs =
        params[:q] && params[:q].values.uniq != [''] ?
            Observation.search(params[:q]).result.preload(:locus, :species).limit(params[:limit]) :
            []
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
    possible_keys = [:locus_id, :observ_date, :mine, :post_id]
    @observations = [Observation.new(params.slice(*possible_keys))]
    @blogpost = @observations.first.post
    render :bulk
  end

  # GET /observations/1/edit
  def edit
    render :form
  end

  # GET /observations/bulk
  # Bulk edit observations
  def bulk
    required_keys = [:locus_id, :observ_date, :mine]
    meaningful_keys = required_keys + [:species_id, :post_id]
    if params.values_at(*required_keys).map(&:present?).uniq == [true] && (@observations = Observation.where(params.slice(*meaningful_keys)).all).present?
      render
    else
      redirect_to add_observations_url(params.slice(*required_keys))
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

  # GET "/observations/with_spots.json"
  def with_spots
    observs =
        params[:q] && params[:q].values.uniq != [''] ?
            Observation.search(params[:q]).result.preload(:locus, :species, :spots) :
            []
    respond_with(observs, :only => :id, :methods => [:species_str, :when_where_str, :spots])
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :photos, format: 'xml'
  end
end