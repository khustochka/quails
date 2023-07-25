# frozen_string_literal: true

class ImagesController < ApplicationController
  include FlickrConcern

  administrative except: [:index, :multiple_species, :show, :gallery, :country]
  localized only: [:index, :multiple_species, :show, :gallery, :country]

  find_record by: :slug, before: [:show, :edit,
    :parent_edit, :parent_update,
    :map_edit, :update, :patch, :destroy,]

  after_action :cache_expire, only: [:create, :update, :destroy]

  # Latest additions
  def index
    if params[:page].to_i == 1
      redirect_to page: nil
    else
      page = (params[:page] || 1).to_i
      @images = Image.preload(:species).order(created_at: :desc).page(page).per(24)
      @feed = "photos"
      @cell0 = YearSummaryCell.new(year: 2022)
      @cell = YearProgressCell.new(year: Quails::CURRENT_YEAR)
      if @images.empty? && page != 1
        raise ActiveRecord::RecordNotFound
      else
        render :index
      end
    end
  end

  # Photos of multiple species
  def multiple_species
    @images = Image.multiple_species
  end

  # GET /photos/1
  def show
    respond_to do |format|
      format.html do
        @robots = "NOINDEX" if @image.status == "NOINDEX"
      end
      format.jpeg do
        redirect_to helpers.jpg_url(@image)
      end
    end
  end

  # GET /photos/new
  def new
    @image = Image.new
    render "form"
  end

  # GET /photos/1/edit
  def edit
    @photo = FlickrPhoto.new(@image)
    render "form"
  end

  # TODO: Probably merge with flickr_photo#create
  def upload
    to_flickr = params[:to_flickr]
    uploaded_io = params[:image]
    path = to_flickr ? helpers.temp_image_path : helpers.local_image_path
    filename = File.join(path, uploaded_io.original_filename)
    File.open(filename, "wb") do |file|
      file.write(uploaded_io.read)
    end
    new_slug = File.basename(uploaded_io.original_filename, ".*")
    image_attributes = { i: { slug: new_slug } }
    exif_date = `identify -format "%[EXIF:DateTimeOriginal]" "#{filename}"`.chomp[0..9].tr(":", "-")
    image_attributes[:exif_date] = exif_date if exif_date.present?
    if to_flickr
      flickr_id = _FlickrClient.upload_photo(filename, FlickrPhoto::DEFAULT_PARAMS.merge(params[:flickr])).get
      image_attributes[:i][:flickr_id] = flickr_id
      image_attributes[:new_on_flickr] = true
    end
    redirect_to new_image_path(image_attributes)
  end

  # GET /photos/1/map_edit
  def map_edit
    @spot = Spot.new(public: true)
  end

  # POST /photos
  def create
    @image = Image.new(image_params)

    flickr_id = params[:image][:flickr_id]

    @photo = FlickrPhoto.new(@image)
    @photo.bind_with_flickr(flickr_id)

    if @image.save
      FlickrUploadJob.perform_later(@image, { public: true }) if params[:upload_to_flickr]
      redirect_to(edit_map_image_path(@image), notice: "Image was successfully created. Map it now!")
    else
      render "form"
    end

    # if @image.update(image_params)
    #
    #   if params[:new_on_flickr]
    #     @photo.update!
    #   end
    #
    #   if helpers.local_image_path && !Rails.env.test?
    #     full_path = File.join(helpers.local_image_path, "#{image_params[:slug]}.jpg")
    #     if File.exist?(full_path)
    #       w, h = `identify -format "%Wx%H" #{full_path}`.split('x').map(&:to_i)
    #       @image.assets_cache << ImageAssetItem.new(:local, w, h, "#{image_params[:slug]}.jpg")
    #       @image.save!
    #     end
    #   end
    #
    #   redirect_to(edit_map_image_path(@image), :notice => 'Image was successfully created. Map it now!')
    # else
    #   render 'form'
    # end
  end

  # PUT /photos/1
  def update
    if @image.update(image_params)
      if @image.mapped?
        redirect_to(image_path(@image))
      else
        redirect_to(edit_map_image_path(@image), notice: "Image was successfully updated. Map it now!")
      end
    else
      render "form"
    end
  end

  # POST /photos/1/patch
  def patch
    new_params = params[:image]
    respond_to do |format|
      if @image.update(new_params)
        format.html { redirect_to action: :show }
        format.json { head :no_content }
      else
        format.html { render "form" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end

  private

  ACCEPTED_PARAMS = [:slug, :title, :description, :index_num, :status, :stored_image]

  def image_params
    @image_params ||= params.require(:image).permit(*ACCEPTED_PARAMS).merge(observation_ids: params[:obs] || [])
  end

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: "xml"
    expire_page controller: :feeds, action: :instant_articles, format: "xml"
    expire_photo_feeds
    expire_page controller: :feeds, action: :sitemap, format: "xml"
  end
end
