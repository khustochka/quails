class MapsController < ApplicationController
  respond_to :html, :only => [:index, :edit]

  administrative :except => [:show]

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
    preload_tables = [{:card => :locus}, :species, :spots, :images]
    json_methods = [:spots]

    # Have to do outer join to preserve Avis incognita
    observs =
        params[:q] && params[:q].delete_if { |_, v| v.empty? }.present? ?
            ObservationSearch.new(params[:q]).observations.
                joins("LEFT OUTER JOIN species ON species_id = species.id").
                preload(preload_tables).
                order('cards.observ_date', 'cards.locus_id', 'species.index_num').limit(params[:limit] || 200) :
            []

    respond_to do |format|
      format.json { render json:
                               { json: observs.as_json(only: :id, methods: json_methods),
                                 html: render_to_string(partial: 'maps/observation', collection: observs, formats: [:html]) }
      }
    end
  end

end
