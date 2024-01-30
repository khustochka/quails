# frozen_string_literal: true

module API
  class LociController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      @loci = Locus.order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)

      respond_to do |format|
        format.json {
          render json: @loci
        }
      end
    end
  end
end
