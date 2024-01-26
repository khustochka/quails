# frozen_string_literal: true

module API
  class LociController < APIController
    def index
      @loci = Locus.all

      respond_to do |format|
        format.json {
          render json: @loci
        }
      end
    end
  end
end
