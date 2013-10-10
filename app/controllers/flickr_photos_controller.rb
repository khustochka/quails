class FlickrPhotosController < ApplicationController

  administrative

  before_filter :find_image, only: [:show, :create, :edit, :destroy]

  def new
    if FlickrApp.configured?
      begin
        @flickr_images = flickr.photos.search({user_id: Settings.flickr_admin.user_id,
                                               extras: 'date_taken',
                                               per_page: 10})
      rescue FlickRaw::FailedResponse => e
        flash[:alert] = "No Flickr API key defined!"
      end
    end
  end

  def show
    @next = Image.where(flickr_id: nil).where('created_at < ?', @image.created_at).order('created_at DESC').first
  end

  def edit

  end

  # This is flickr upload and attach to flickr
  # Maybe should be separate actions
  def create
    new_flickr_id = params[:flickr_id]
    if new_flickr_id
      @photo.bind_with_flickr!(new_flickr_id)
    else
      raise "The image is already on flickr" if @image.on_flickr?
      @photo.upload(params)
    end
    redirect_to flickr_photo_path(@image)
  end

  def destroy
    @photo.detach!
    redirect_to flickr_photo_path(@image)
  end

  private
  def find_image
    @image = Image.find_by_slug(params[:id])
    @photo = FlickrPhoto.new(@image)
  end

end
