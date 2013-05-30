class ImagesController < ApplicationController

  cache_sweeper :gallery_sweeper

  respond_to :json, only: [:flickr_search, :observations]

  administrative except: [:index, :multiple_species, :show, :gallery, :country]

  find_record by: :slug, before: [:show, :edit, :flickr_edit, :map_edit, :update, :patch, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # Latest additions
  def index
    redirect_to page: nil if params[:page].to_i == 1
    @images = Image.preload(:species).order('created_at DESC').page(params[:page].to_i).per(24)
    @feed = 'photos'
  end

  # Photos of multiple species
  def multiple_species
    @images = Image.multiple_species
  end

  # GET /photos/1
  def show
  end

  # GET /photos/add # select flickr photo
  def add
    if FlickrApp.configured?
      @flickr_images = flickr.photos.search({user_id: Settings.flickr_admin.user_id,
                                             extras: 'date_taken',
                                             per_page: 10})
    else
      redirect_to({action: :new}, alert: "No Flickr API key or secret defined!")
    end
  rescue FlickRaw::FailedResponse => e
    redirect_to({action: :new}, alert: e.message)
  end

  # GET /photos/new
  def new
    @image = Image.new(params[:i])
    @image.set_flickr_data(flickr)

    render 'form'
  end

  # GET /photos/1/edit
  def edit
    render 'form'
  end

  def unflickred
    @images = Image.preload(:species).where(flickr_id: nil).order('created_at DESC').page(params[:page].to_i).per(24)
  end

  # GET /photos/1/flickr_edit
  def flickr_edit
    @next = Image.where(flickr_id: nil).where('created_at < ?', @image.created_at).order('created_at DESC').first
  end

  # GET /photos/1/map_edit
  def map_edit
    @spot = Spot.new(public: true)
  end

  # POST /photos
  def create
    @image = Image.new

    @image.set_flickr_data(flickr, params[:image])

    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(image_path(@image), :notice => 'Image was successfully created.')
    else
      render 'form'
    end
  end

  # PUT /photos/1
  def update
    new_params = params[:image]
    if @image.update_with_observations(new_params, params[:obs])
      redirect_to(image_path(@image), :notice => 'Image was successfully updated.')
    else
      render 'form'
    end
  end

  # POST /photos/1/patch
  def patch
    new_params = params[:image]
    if new_params[:flickr_id]
      @image.set_flickr_data(flickr, new_params)
      @image.save
    end
    respond_to do |format|
      if @image.update_attributes(new_params)
        format.html { redirect_to action: 'edit' }
        # Have to return something because empty response (head :ok) is not valid JSON and is not considered $.ajax success
        format.json { render json: @image, only: new_params.keys + [:id] }
      else
        format.html { render 'form' }
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end

  # GET /observations
  def observations
    observs = Image.find_by_id(params[:id]).observations.preload(:species, :card => :locus)
    respond_with(observs, :only => :id, :methods => [:species_str, :when_where_str])
  end

  # GET /flickr_search
  def flickr_search
    dates_params =
        if params[:flickr_date].present?
          date_param = Date.parse(params[:flickr_date])
          {min_taken_date: date_param - 1, max_taken_date: date_param + 1}
        else
          {}
        end

    result =
        params[:flickr_text].blank? ?
            [] :
            flickr.photos.search(
                {user_id: Settings.flickr_admin.user_id,
                 extras: 'date_taken,url_s',
                 text: params[:flickr_text]}.merge(dates_params)
            ).map(&:to_hash)

    respond_with(result, only: %w(id title datetaken url_s))
  rescue FlickRaw::FailedResponse => e
    respond_with({error: e.message}, status: :error)
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end
end
