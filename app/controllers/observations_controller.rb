class ObservationsController < ApplicationController

  administrative

  find_record before: [:edit, :update, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]
  cache_sweeper :lifelist_sweeper

  # GET /observations
  def index
    @search = Observation.search(params[:q])
    # sorting by species.index_num requires using #includes
    # but #preload is faster, so use it for locus and post, and for species if possible
    # TODO: when Rails 4 is out look at #references
    @observations = @search.order(params[:sort]).preload(:locus, :post).page(params[:page]).
        send((params[:sort] == 'species.index_num') ? :includes : :preload, :species)
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

  # GET /observations/1/edit
  def edit
    render :form
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

  # GET /observations/search(/with_spots).json
  def search
    preload_tables = [:locus, :species]
    json_methods = [:species_str, :when_where_str]
    if params[:with_spots]
      preload_tables << :spots
      json_methods << :spots
    end

    # Have to do outer join to preserve Avis incognita
    observs =
        params[:q] && params[:q].delete_if { |_, v| v.empty? }.present? ?
            Observation.search(params[:q]).
                joins("LEFT OUTER JOIN species ON species_id = species.id").
                preload(preload_tables).
                order(:observ_date, :locus_id, :index_num).limit(params[:limit] || 200) :
            []

    respond_to do |format|
      format.html { render partial: 'observations/obs_item', collection: observs }
      format.json { render json: observs, only: :id, methods: json_methods }
    end
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :blog, format: 'xml'
  end
end
