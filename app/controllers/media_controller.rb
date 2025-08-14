# frozen_string_literal: true

class MediaController < ApplicationController
  administrative except: [:strip]
  localized only: [:strip]

  # Do not check csrf token for photostrip on the map
  skip_forgery_protection only: :strip

  def strip
    @strip = true
    @strip_media = Media.where(id: params[:_json]).includes(:cards, :species)
      .order("cards.observ_date, cards.locus_id, media.index_num, species.index_num")
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
    @media = media.preload(taxa: :species).order(created_at: :desc).page(params[:page].to_i).per(24)
  end
end
