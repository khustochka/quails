class ImagesController < ApplicationController

  respond_to :json, only: [:flickr_search, :observations]

  administrative except: [:photostream, :show]

  find_record by: :slug, before: [:show, :edit, :update, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # GET /images
  def index
    @images = Image.page(params[:page])
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

  # GET /images/new
  def new
    @image = Image.new
    render 'form'
  end

  # GET /images/1/edit
  def edit
    @extra_params = @image.to_url_params
    render 'form'
  end

  # POST /images
  def create
    @image = Image.new

    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render 'form'
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params

    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      render 'form'
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
    date_param = params[:flickr_date]
    dates_params = date_param.present? ?
        {min_taken_date: date_param - 1, max_taken_date: date_param + 1} :
        {}
    result =
        params[:flickr_text].blank? ?
            [] :
            flickr.photos.search(
                {user_id: '8289389@N04',
                 extras: 'date_taken,url_s',
                 text: params[:flickr_text]}.merge(dates_params)
            ).map(&:to_hash)

    respond_with( result, only: %w(title datetaken url_s) )
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end
end
