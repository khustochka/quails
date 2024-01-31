# frozen_string_literal: true

module API
  class ObservationsController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      obs_sql = Observation.select("observations.*, taxa.ebird_code").joins(:taxon).order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
      obs = ActiveRecord::Base.connection.select_all(obs_sql)

      respond_to do |format|
        format.json {
          render json: { columns: obs.columns, rows: obs.rows }
        }
      end
    end
  end
end
