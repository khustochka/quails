class ImagesController < ApplicationController

  respond_to :json, only: [:flickr_search, :observations]

  administrative except: [:photostream, :show, :gallery]

  find_record by: :slug, before: [:show, :edit, :flickr_edit, :map_edit, :update, :patch, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # GET /images
  def index
    @images = Image.page(params[:page])
  end

  # Galleries
  def gallery
    @country = Locus.find_by_slug(params[:country])
    @species = @country.species.preload(:image).ordered_by_taxonomy.all.extend(SpeciesArray)
  end

  # GET /photostream
  def photostream
    redirect_to page: nil if params[:page].to_i == 1
    @robots = 'NOINDEX, NOARCHIVE' if params[:page]
    @images = Image.order('created_at DESC').page(params[:page]).per(20)
    @feed = 'photos'
  end

  # GET /images/1
  def show
    if params[:species] != @image.species_for_url
      redirect_to @image.to_url_params, :status => 301
    end
  end

  # GET /images/add # select flickr photo
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

  # GET /images/new
  def new
    @image = Image.new(params[:i])
    @image.set_flickr_data(flickr)

    render 'form'
  end

  # GET /images/1/edit
  def edit
    @extra_params = @image.to_url_params
    render 'form'
  end

  # GET /images/1/flickr_edit
  def flickr_edit
    @extra_params = @image.to_url_params
  end

  # GET /images/1/map_edit
  def map_edit
    @extra_params = @image.to_url_params
    @spot = Spot.new(public: true)
  end

  # POST /images
  def create
    @image = Image.new

    @image.set_flickr_data(flickr, params[:image])

    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render 'form'
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params
    new_params = params[:image]
    if @image.update_with_observations(new_params, params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      render 'form'
    end
  end

  # POST /images/1/patch
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

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end

  # GET /observations
  def observations
    observs = Image.find_by_id(params[:id]).observations.preload(:locus, :species)
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
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end
end
