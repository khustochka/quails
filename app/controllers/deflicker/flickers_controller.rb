module Deflicker
  class FlickersController < ApplicationController

    administrative

    def index
      @search = Deflicker::Search.new(search_params)
      @photos = @search.result.order_by(:uploaded_at => :asc).page(params[:page]).per(10)
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
      raise "Destroy not yet implemented!"
      flicker = Flicker.find_by(flickr_id: params[:id])
      if flicker.removed?
        flash[:alert] = "Already removed"
      else
        if flicker.journal_entry_ids.empty?
          Image.transaction do
            if flicker.allow_delete?
              if flicker.on_site?
                fp = FlickrPhoto.new(flicker.image)
                fp.detach! if Rails.env.production?
              end
              if Rails.env.production?
                # TODO: Actually remove
              else
                # "Fake remove"
              end
              flicker.update(removed: true) if Rails.env.production?
              flash[:notice] = "Removed! #{helpers.link_to "Flickr", flicker.url, target: :_blank}
                                #{helpers.link_to "Image", flicker.image, target: :_blank}"
            else
              flash[:alert] = "Not yet on S3"
            end
          end
        else
          flash[:alert] = "Still has journal entries"
        end
        redirect_to deflicker_path
      end
    end

    private

    def search_params
      params.slice(*Deflicker::Search.attribute_names)
    end

  end
end
