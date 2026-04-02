# frozen_string_literal: true

class MapsController < ApplicationController
  layout "application2", only: [:show]

  administrative except: [:show, :media]
  localized only: [:show, :media]

  # GET "/map"
  def show
  end

  # GET "/map/edit"
  def edit
    search_params = params[:q]
    unless search_params&.values&.any?(&:present?)
      latest_date = Card.maximum(:observ_date)
      search_params = { observ_date: latest_date } if latest_date
    end
    @observation_search = ObservationSearch.new(search_params)
    @spot = Spot.new(public: true)
  end

  # GET "/map/observations.json"
  def observations
    preload_tables = [{ card: :locus }, { taxon: :species }, :spots, :images]
    json_methods = [:spots]

    observs =
      # TODO: the goal is to avoid loading all observations (thousands!) if all filters are empty
      # Needs refactoring to only take into account meaningful fields (not "exclude subspecies")
      params[:q]&.values&.any?(&:present?) ?
        ObservationSearch.new(params[:q]).observations
          .joins(:card, :taxon)
          .preload(preload_tables)
          .order("cards.observ_date", "cards.locus_id", "taxa.index_num").limit(params[:limit] || 200) :
        []

    respond_to do |format|
      format.json {
        render json:
        { json: observs.as_json(only: :id, methods: json_methods),
          html: render_to_string(partial: "maps/observation", collection: observs, formats: [:html]), }
      }
    end
  end

  # GET "/map/media.json"
  def media
    render json: Media.for_the_map
  end

  def global
  end

  def loci
    render json: Card.joins(:locus).where.not(loci: { lat: nil }).distinct.pluck(:lat, :lon)
  end
end
