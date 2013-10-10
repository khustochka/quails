class FlickrPhotosController < ApplicationController

  administrative

  before_filter :find_image, only: [:show, :create, :edit, :update, :destroy]

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

  def update
    @photo.update(params)
    redirect_to action: :edit
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

  # Collection actions

  def unflickred
    @images = Image.preload(:species).where(flickr_id: nil).order('created_at DESC').page(params[:page].to_i).per(24)
  end

  def unused
    used = Image.where("flickr_id IS NOT NULL").pluck(:flickr_id)
    page = 0
    all = []
    begin
      result = flickr.photos.search({user_id: Settings.flickr_admin.user_id, per_page: 500, page: (page += 1)})
      all += result.to_a
    end until result.size == 0
    @diff = all.reject { |x| used.include?(x.id) }
  end

  private
  def find_image
    @image = Image.find_by_slug(params[:id])
    @photo = FlickrPhoto.new(@image)
  end

end
