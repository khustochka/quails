# frozen_string_literal: true

module API
  class ObservationsController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      @observations = Observation.select("observations.*, taxa.ebird_code").joins(:taxon).order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)

      respond_to do |format|
        format.json {
          render json: @observations
        }
      end
    end
  end
end
