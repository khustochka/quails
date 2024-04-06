# frozen_string_literal: true

module API
  class LociController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      loci_sql = Locus.order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE).to_sql
      loci = ActiveRecord::Base.connection.select_all(loci_sql)

      respond_to do |format|
        format.json {
          render json: { columns: loci.columns, rows: loci.rows }
        }
      end
    end
  end
end
