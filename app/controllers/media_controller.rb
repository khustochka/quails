class MediaController < ApplicationController

  # Do not check csrf token for photostrip on the map
  skip_before_action :verify_authenticity_token, only: :strip

  def strip
    @media = Media.where(id: params[:_json]).includes(:cards, :species).
        order('cards.observ_date, cards.locus_id, media.index_num, species.index_num')
    render layout: false
  end

end
