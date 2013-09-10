class ImagesController < ApplicationController

  respond_to :json, only: [:flickr_search, :observations]

  administrative except: [:index, :multiple_species, :show, :gallery, :country, :strip]

  find_record by: :slug, before: [:show, :edit, :flickr_edit, :flickr_upload, :map_edit, :update, :patch, :destroy]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # Do not check csrf token for photostrip on the map
  skip_before_filter :verify_authenticity_token, only: :strip

  # Latest additions
  def index
    redirect_to page: nil if params[:page].to_i == 1
    @images = Image.preload(:species).order('created_at DESC').page(params[:page].to_i).per(24)
    @feed = 'photos'
    if @images.empty? && params[:page].to_i != 1
      raise ActiveRecord::RecordNotFound
    else
      render :index
    end
  end

  # Photos of multiple species
  def multiple_species
    @images = Image.multiple_species
  end

  # GET /photos/1
  def show
    @robots = 'NOINDEX' if @image.status == 'NOIDX'
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

  # POST /photos/upload
  def upload
    uploaded_io = params[:image]
    File.open(File.join(ImagesHelper.local_image_path, uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    new_slug = File.basename(uploaded_io.original_filename, '.*')
    redirect_to action: :new, i: {slug: new_slug}
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

  def unflickred
    @images = Image.preload(:species).where(flickr_id: nil).order('created_at DESC').page(params[:page].to_i).per(24)
  end

  def half_mapped
    @images = Image.half_mapped.page(params[:page].to_i).per(24)
  end

  # GET /photos/1/flickr_edit
  def flickr_edit
    @next = Image.where(flickr_id: nil).where('created_at < ?', @image.created_at).order('created_at DESC').first
  end

  # POST /photos/1/flickr
  def flickr_upload
    raise "The image is already on flickr" if @image.on_flickr?
    flickr_id = flickr.upload_photo local_image_url(@image),
                                    title: (@image.species.map { |s| "#{s.name_en}; #{s.name_sci}" }.join('; ')),
                                    description: "#{l(@image.observ_date, format: :long, locale: :en)}\n#{@image.locus.name_en}, #{@image.locus.country.name_en}",
                                    tags: %Q(#{@image.species.map { |s| "\"#{s.name_en}\" \"#{s.name_sci}\"" }.join(' ')} bird #{@image.locus.country.name_en} #{@image.species.map(&:order).uniq.join(' ')} #{@image.species.map(&:family).uniq.join(' ')}),
                                    is_public: params[:public],
                                    safety_level: 1,
                                    content_type: 1

    @image.set_flickr_data(flickr, flickr_id)
    @image.save!
    redirect_to edit_flickr_image_path(@image)
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

    @image.set_flickr_data(flickr, flickr_id)

    if @image.update_with_observations(params[:image], params[:obs])

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
    new_flickr_id = new_params.delete(:flickr_id)
    if new_flickr_id
      @image.set_flickr_data(flickr, new_flickr_id)
      @image.save
    end
    respond_to do |format|
      if @image.update_attributes(new_params)
        format.html { redirect_to action: new_flickr_id ? 'flickr_edit' : 'show' }
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

  # GET /flickr_search
  def flickr_search
    dates_params =
        if params[:flickr_date].present?
          date_param = Date.parse(params[:flickr_date])
          {min_taken_date: date_param - 1, max_taken_date: date_param + 1}
        else
          {}
        end

    result = flickr.photos.search(
        {user_id: (params[:flickr_user_id] || Settings.flickr_admin.user_id),
         extras: 'date_taken,url_s',
         text: params[:flickr_text]}.merge(dates_params)
    ).map(&:to_hash)

    respond_with(result, only: %w(id title datetaken url_s))
  rescue FlickRaw::FailedResponse => e
    respond_with({error: e.message}, status: :error)
  end

  def strip
    @images = Image.where(id: params[:_json]).includes(:cards, :species).
        order('cards.observ_date, cards.locus_id, images.index_num, species.index_num')
    render layout: false
  end

  private

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end

  def local_image_url(img)
    prefix = ImagesHelper.local_image_path || ImagesHelper.image_host
    "#{prefix}/#{img.slug}.jpg"
  end
end
