# frozen_string_literal: true

module API
  class CardsController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      cards_sql = Card.order(:id).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
      cards = ActiveRecord::Base.connection.select_all(cards_sql)

      respond_to do |format|
        format.json {
          render json: { columns: cards.columns, rows: cards.rows }
        }
      end
    end
  end
end
