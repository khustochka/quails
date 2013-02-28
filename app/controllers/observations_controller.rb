class ObservationsController < ApplicationController

  BULK_REQUIRED_KEYS = %w(locus_id observ_date mine)
  BULK_MEANINGFUL_KEYS = BULK_REQUIRED_KEYS + %w(species_id voice post_id)

  respond_to :json, only: [:bulksave]

  administrative

  find_record before: [:edit, :update, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy, :bulksave]

  # GET /observations
  def index
    @search = Observation.search(params[:q])
    # sorting by species.index_num requires using #includes
    # but #preload is faster, so use it for locus and post, and for species if possible
    # TODO: when Rails 4 is out look at #references
    @observations = @search.order(params[:sort]).preload(:locus, :post).page(params[:page]).
        send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)

    # TODO: extract to model; add tests
    common = @observations.map(&:attributes).inject(:&) || {}
    @common = common.slice(*BULK_MEANINGFUL_KEYS)
    @common = nil if @common.values_at(*BULK_REQUIRED_KEYS).any?(&:nil?)
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
    required_keys = params.slice(*BULK_REQUIRED_KEYS)
    @observations = Observation.where(params.slice(*BULK_MEANINGFUL_KEYS))
    if params.values_at(*BULK_REQUIRED_KEYS).any?(&:nil?) || @observations.blank?
      redirect_to add_observations_url(required_keys)
    else
      render
    end
  end

  # POST /observations
  def create
    ob = params[:o].first
    ob[:voice] ||= false
    @observation = Observation.new(params[:c].merge(ob))

    if @observation.save
      redirect_to(@observation, :notice => 'Observation was successfully created.')
    else
      render :form
    end
  end

  # PUT /observations/1
  def update
    ob = params[:o].first
    ob[:voice] ||= false
    params[:c][:post_id] ||= nil
    if @observation.update_attributes(params[:c].merge(ob))
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

  # POST /observations/bulksave.json
  # API: parameters are a hash with two keys:
  # c: hash of common options - locus_id, observ_date, mine, post_id
  # o: array of hashes each having species_id, quantity, biotope, place, notes
  def bulksave
    obs_bunch = ObservationBulk.new(params)
    obs_bunch.save
    respond_with(obs_bunch, :location => observations_url, :only => :id)
  end

  # GET /observations/search(/with_spots).json
  def search
    preload_tables = [:locus, :species]
    json_methods = [:species_str, :when_where_str]
    if params[:with_spots]
      preload_tables << :spots
      json_methods << :spots
    end
    observs =
        params[:q] && params[:q].delete_if { |_, v| v.empty? }.present? ?
            Observation.search(params[:q]).preload(preload_tables).order(:observ_date, :locus_id).limit(params[:limit]) :
            []

    respond_to do |format|
      format.html { render partial: 'observations/obs_item', collection: observs }
      format.json { render json: observs, only: :id, methods: json_methods }
    end
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :photos, format: 'xml'
  end
end
