# frozen_string_literal: true

module Deflicker
  class FlickersController < ApplicationController
    administrative

    include FlickrConcern

    def index
      @search = Deflicker::Search.new(search_params)
      @photos = @search.result.order_by(uploaded_at: :asc).page(params[:page]).per(10)
    end

    def refresh
      FlickrLoadJob.perform_later
      redirect_to deflicker_path
    end

    def rematch
      SiteMatchJob.perform_later
      redirect_to deflicker_path
    end

    def destroy
      flicker = Flicker.find_by(flickr_id: params[:id])
      if flicker.removed?
        flash.now[:alert] = "Already removed"
      else
        if flicker.journal_entry_ids.empty? || flicker.journal_entries_fixed?
          Image.transaction do
            if flicker.allow_delete?
              if Rails.env.production?
                result = _FlickrClient.call("flickr.photos.delete", photo_id: flicker.flickr_id)
                if result.valid?
                  if flicker.on_site?
                    fp = FlickrPhoto.new(flicker.image)
                    fp.detach! if Rails.env.production?
                  end
                  flicker.update(removed: true) if Rails.env.production?
                  flash.now[:notice] =
                    "Removed! #{helpers.link_to "Flickr", flicker.url, target: :_blank, rel: :noopener}
                    #{helpers.link_to "Image", flicker.image, target: :_blank, rel: :noopener}"
                else
                  flash.now[:alert] = result.errors.full_messages.join(" ")
                end
              else
                flash[:alert] = "Fake removed"
              end
            else
              flash.now[:alert] = "Not yet on S3"
            end
          end
        else
          flash[:alert] = "Still has journal entries"
        end
        if request.xhr?
          head :ok
        else
          redirect_to deflicker_path
        end
      end
    end

    def fixed
      flicker = Flicker.find_by(flickr_id: params[:id])
      flicker.update(journal_entries_fixed: true)
    end

    private

    def search_params
      params.slice(*Deflicker::Search.attribute_names)
    end
  end
end
