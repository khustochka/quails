class ObservationsController < ApplicationController

  administrative

  find_record before: [:show, :update, :destroy]

  after_filter :cache_expire, only: [:update, :destroy]
  cache_sweeper :lifelist_sweeper

  # GET /observations/1
  def show
  end

  # PUT /observations/1
  def update
    if @observation.update_attributes(params[:observation])
      redirect_to(observation_path(@observation), :notice => 'Observation was successfully updated.')
    else
      render :form
    end
  end

  # DELETE /observations/1
  def destroy
    @observation.destroy

    head :no_content
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
