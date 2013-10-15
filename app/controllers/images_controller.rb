class ImagesController < ApplicationController

  respond_to :json, only: [:observations, :parent_update]

  administrative except: [:index, :multiple_species, :show, :gallery, :country, :strip]

  find_record by: :slug, before: [:show, :edit,
                                  :parent_edit, :parent_update,
                                  :map_edit, :update, :patch, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # Do not check csrf token for photostrip on the map
  skip_before_filter :verify_authenticity_token, only: :strip

  # Latest additions
  def index
    if params[:page].to_i == 1
      redirect_to page: nil
    else
      @images = Image.preload(:species).order('created_at DESC').page(params[:page].to_i).per(24)
      @feed = 'photos'
      if @images.empty? && params[:page].to_i != 1
        raise ActiveRecord::RecordNotFound
      else
        render :index
      end
    end
  end

  # Photos of multiple species
  def multiple_species
    @images = Image.multiple_species.top_level
  end

  # GET /photos/1
  def show
    @robots = 'NOINDEX' if @image.status == 'NOIDX' || @image.parent_id
  end

  # GET /photos/new
  def new
    @image = Image.new(params[:i])

    render 'form'
  end

  # GET /photos/1/edit
  def edit
    render 'form'
  end

  # TODO: Probably merge with flickr_photo#create
  def upload
    to_flickr = params[:to_flickr]
    uploaded_io = params[:image]
    path = to_flickr ? ImagesHelper.temp_image_path : ImagesHelper.local_image_path
    filename = File.join(path, uploaded_io.original_filename)
    File.open(filename, 'wb') do |file|
      file.write(uploaded_io.read)
    end
    new_slug = File.basename(uploaded_io.original_filename, '.*')
    image_attributes = {i: {slug: new_slug}}
    if to_flickr
      flickr_id = FlickrPhoto.upload_file(filename)
      image_attributes[:i][:flickr_id] = flickr_id
      image_attributes[:new_on_flickr] = true
    end
    redirect_to new_image_path(image_attributes)
  end

  def half_mapped
    @images = Image.half_mapped.page(params[:page].to_i).per(24)
  end

  # GET /photos/1/map_edit
  def map_edit
    @spot = Spot.new(public: true)
  end

  # POST /photos
  def create
    @image = Image.new

    flickr_id = params[:image].delete(:flickr_id)
    params[:image].slice!(*Image::NORMAL_PARAMS)

    @photo = FlickrPhoto.new(@image)
    @photo.bind_with_flickr(flickr_id)

    if @image.update_with_observations(params[:image], params[:obs])

      if params[:new_on_flickr]
        @photo.update!
      end

      if ImagesHelper.local_image_path && !Rails.env.test?
        full_path = File.join(ImagesHelper.local_image_path, "#{params[:image][:slug]}.jpg")
        if File.exist?(full_path)
          w, h = `identify -format "%Wx%H" #{full_path}`.split('x').map(&:to_i)
          @image.assets_cache << ImageAssetItem.new(:local, w, h, "#{params[:image][:slug]}.jpg")
          @image.save!
        end
      end

      redirect_to(edit_map_image_path(@image), :notice => 'Image was successfully created. Map it now!')
    else
      render 'form'
    end
  end

  # PUT /photos/1
  def update
    new_params = params[:image].slice(*Image::NORMAL_PARAMS)
    if @image.update_with_observations(new_params, params[:obs])
      if @image.mapped?
        redirect_to(image_path(@image), notice: 'Image was successfully updated.')
      else
        redirect_to(edit_map_image_path(@image), notice: 'Image was successfully updated. Map it now!')
      end
    else
      render 'form'
    end
  end

  # POST /photos/1/patch
  def patch
    new_params = params[:image]
    respond_to do |format|
      if @image.update_attributes(new_params)
        format.html { redirect_to action: :show }
        format.json { head :no_content }
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

  def strip
    @images = Image.where(id: params[:_json]).includes(:cards, :species).
        order('cards.observ_date, cards.locus_id, images.index_num, species.index_num')
    render layout: false
  end

  def parent_edit
    @similar_images = Image.uniq.joins(:observations).
        where('observations.id' => @image.observation_ids).
        where("images.id <> #{@image.id}").basic_order
  end

  def parent_update
    new_id = params[:parent_id]
    if new_id
      new_parent = Image.find(new_id)
      if new_parent.parent_id
        raise "This is a child image"
      end
    end

    Image.connection.transaction do
      @image.children.update_all(parent_id: new_id)
      @image.update_attribute(:parent_id, new_id)
    end
    head :no_content

  end

  def series
    rel = Observation.select(:observation_id).from("images_observations").group(:observation_id).having("COUNT(image_id) > 1")
    @observations = Observation.select("DISTINCT observations.*, observ_date").where(id: rel).
        joins(:card).preload(:images).order('observ_date DESC').page(params[:page])
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end
end
