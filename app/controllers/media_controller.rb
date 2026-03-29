# frozen_string_literal: true

class MediaController < ApplicationController
  administrative except: [:strip]
  localized only: [:strip]

  # Do not check csrf token for photostrip on the map
  skip_forgery_protection only: :strip

  # Client sends ALL media IDs on every request with offset/limit for pagination.
  # This is because the server sorts by observ_date (via cards join), and the client
  # cannot know that order — cluster markers group IDs by location, not chronology.
  def strip
    @strip = true
    ids = params[:_json]
    offset = params[:offset].to_i
    limit = (params[:limit].presence&.to_i)

    scope = Media.where(id: ids).includes(:cards, :species)
      .order("cards.observ_date, cards.locus_id, media.index_num, species.index_num")
    scope = scope.offset(offset) if offset > 0
    scope = scope.limit(limit) if limit

    @strip_media = scope
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
