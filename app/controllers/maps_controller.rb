class MapsController < ApplicationController

  administrative :except => [:show, :media]

  # GET "/map"
  def show

  end

  # GET "/map/edit"
  def edit
    @observation_search = ObservationSearch.new(params[:q])
    @spot = Spot.new(public: true)
  end

  # GET "/map/observations.json"
  def observations
    preload_tables = [{:card => :locus}, {:taxon => :species}, :spots, :images]
    json_methods = [:spots]

    observs =
        params[:q] && params[:q].delete_if { |_, v| v.empty? }.present? ?
            ObservationSearch.new(params[:q]).observations.
                joins(:card, :taxon).
                preload(preload_tables).
                order('cards.observ_date', 'cards.locus_id', 'patch_id', 'taxa.index_num').limit(params[:limit] || 200) :
            []

    respond_to do |format|
      format.json { render json:
                               { json: observs.as_json(only: :id, methods: json_methods),
                                 html: render_to_string(partial: 'maps/observation', collection: observs, formats: [:html]) }
      }
    end
  end

  # GET "/map/media.json"
  def media
    render json: Media.for_the_map
  end

end
