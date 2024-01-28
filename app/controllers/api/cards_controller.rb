# frozen_string_literal: true

module API
  class CardsController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      @cards = Card.order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)

      respond_to do |format|
        format.json {
          render json: @cards
        }
      end
    end
  end
end
