class FlickrPhotosController < ApplicationController

  respond_to :html, :json

  administrative

  include FlickrAbility

  before_filter :find_image, only: [:show, :create, :edit, :update, :destroy]

  after_filter :cache_expire, only: [:create, :destroy]

  def new
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
      @photo.upload(params)
    end
    if request.format.html?
      render :show
    else
      respond_with @photo
    end
  end

  def update
    @photo.update(params)
    redirect_to action: :edit
  end

  def destroy
    @photo.detach!
    if @photo.errors.any?
      render :show
    else
      respond_with @photo
    end
  end

  # Collection actions

  def unflickred
    @images = Image.preload(:species).where(flickr_id: nil).order('created_at DESC').page(params[:page].to_i).per(24)
  end

  def unused
    used = Image.where("flickr_id IS NOT NULL").pluck(:flickr_id)
    page = 0
    top = params[:top]
    top = top.to_i if top
    all = Either.value([])
    begin
      result = flickr.photos.search(
          DEFAULT_SEARCH_PARAMS.merge({user_id: Settings.flickr_admin.user_id, per_page: 500, page: (page += 1)})
      )
      if result.error?
        all = result
        break
      else
        result2 = result.reject { |x| used.include?(x.id) }
        all.concat(result2.get)
      end
    end until result.get.size == 0 || (top && all.get.size >= top)
    @diff = all
    if top
      @diff = @diff.take(top)
    end
    @flickr_img_url_lambda = ->(img) { new_image_path(i: {flickr_id: img.id}) }

    if request.xhr?
      render partial: 'flickr_photos/flickr_images', object: @diff
    else
      render :unused
    end

  end

  DEFAULT_SEARCH_PARAMS = {content_type: 1, extras: 'owner_name'}

  def search
    new_params = params
    date = new_params.delete(:flickr_date)
    @flickr_img_format = new_params.delete(:flickr_img_format)
    if date.present?
      date_param = Date.parse(date)
      new_params.merge!({min_taken_date: date_param - 1, max_taken_date: date_param + 1})
    end
    @flickr_imgs = flickr.photos.search(DEFAULT_SEARCH_PARAMS.merge(new_params))
    render partial: 'flickr_photos/flickr_images', object: @flickr_imgs
  end

  private
  def find_image
    @image = Image.find_by_slug(params[:id])
    @photo = FlickrPhoto.new(@image)
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
  end

end
