class MediaController < ApplicationController

  administrative except: [:strip]

  # Do not check csrf token for photostrip on the map
  skip_before_action :verify_authenticity_token, only: :strip

  def strip
    @media = Media.where(id: params[:_json]).includes(:cards, :species).
        order('cards.observ_date, cards.locus_id, media.index_num, species.index_num')
    render layout: false
  end

  def unmapped
    @half = params[:half]
    media =
        if @half
          Media.half_mapped
        else
          Media.where(spot_id: nil)
        end
    @media = media.order('created_at DESC').page(params[:page].to_i).per(24)
  end

end